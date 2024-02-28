#=======================================================
# Security Groups
#=======================================================
# security-group-public =
 #* outbound = 0.0.0.0/0 any port
 #* inbound = my_ip/32 port 22
resource "aws_security_group" "public_security_group" {
    name = "${var.project_name}-public-security_group"
    description = "public security group for bastion"
    vpc_id =  aws_vpc.project_vpc.id

    ingress {
        from_port = "${var.ssh_port}"
        to_port = "${var.ssh_port}"
        protocol = "tcp"
        cidr_blocks = ["${var.local_ip_cidr_block}"]
    }

    egress {
        from_port = "${var.no_protocol_port}"
        to_port = "${var.no_protocol_port}"
        protocol = "${var.no_protocol}"
        cidr_blocks = ["${var.internet_cidr_block}"]
    }

    tags = {
        Name = "${var.project_name}-public-security_group"
    }
}


# security-group-private =
 #* outbound = 0.0.0.0/0 any port
 #* inbound = 10.12.0.0/16 port 22
resource "aws_security_group" "private_security_group" {
    name = "${var.project_name}-private_security_group"
    description = "private security group for local ec2, ssh from local"
    vpc_id =  aws_vpc.project_vpc.id

    ingress {
        from_port = "${var.ssh_port}"
        to_port = "${var.ssh_port}"
        protocol = "tcp"
        cidr_blocks = [aws_vpc.project_vpc.cidr_block]
    }

    egress {
        from_port = "${var.no_protocol_port}"
        to_port = "${var.no_protocol_port}"
        protocol = "${var.no_protocol}"
        cidr_blocks = ["${var.internet_cidr_block}"]
    }

    tags = {
        Name = "${var.project_name}-private_security_group"
    }
} 


# security-group-efs-private =
 #* outbound = 0.0.0.0/0 any port
 #* inbound = 10.12.0.0/16 port 2049
 # private-route-table =
   #* 10.12.0.0/16 = local

resource "aws_security_group" "private_efs_security_group" {
    name = "${var.project_name}-private-efs-sg"
    description = "private security group for local efs, efs/nfs from local"
    vpc_id =  aws_vpc.project_vpc.id

    ingress {
        from_port = "${var.efs_port}"
        to_port = "${var.efs_port}"
        protocol = "tcp"
        cidr_blocks = [aws_vpc.project_vpc.cidr_block]
    }

    egress {
        from_port = "${var.no_protocol_port}"
        to_port = "${var.no_protocol_port}"
        protocol = "${var.no_protocol}"
        cidr_blocks = ["${var.internet_cidr_block}"]
    }

    tags = {
        Name = "${var.project_name}-private-efs-sg"
    }
}


#=====================================================================
# IAM
#=====================================================================
# iam roles from ec2 to storage services
resource "aws_iam_role" "ec2_storage_role" {
    name = "ec2_storage_role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
        Effect = "Allow",
        Sid = "",
    }],
  })
}

# iam policy creation and attachment


resource "aws_iam_policy" "ec2_efs_policy" {
    name = "ec2_efs_policy"
    description = "Policy for EC2 instances manage EFS file system"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = [
                    "elasticfilesystem:CreateFileSystem",
                    "elasticfilesystem:DeleteFileSystem",
				    "elasticfilesystem:DescribeMountTargets",
                    "ec2:DescribeAvailabilityZones",
                    "ec2:CreateNetworkInterface",
                    "ec2:DeleteNetworkInterface",
                    "ec2:DescribeInstances",
                    "ec2-instance-connect:SendSSHPublicKey"

                ],
                Resource = "*",
                Effect = "Allow",
            },
        ],
    })
}
    
resource "aws_iam_role_policy_attachment" "ec2_efs_rw_attachment" {
    role = aws_iam_role.ec2_storage_role.name
    policy_arn = aws_iam_policy.ec2_efs_policy.arn
}

# iam role ec2 s3 policy attachment
resource "aws_iam_role_policy_attachment" "ec2_s3_rw_policy" {
    role = aws_iam_role.ec2_storage_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# iam instance profile
resource "aws_iam_instance_profile" "ec2_storage_full_access" {
    name = "ec2_storage_full_access"
    role = aws_iam_role.ec2_storage_role.name
}


#================================================================
# SSH Keys
#================================================================

# create an ssh key pair on aws and use it latter on the ec2_instaces

# specify private key format
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits =  4096
}
# create on aws
resource "aws_key_pair" "ssh_key" {
    key_name =  "${var.project_name}-key"
    public_key = tls_private_key.rsa.public_key_openssh
}

# download private key for latter attach to ec2_public instance
# TODO: consider sensative if posible

resource "local_file" "ssh_openssh_private_key" { 
    content =  tls_private_key.rsa.private_key_openssh
    filename = "${var.project_name}.pem"
  
}

resource "local_file" "ssh_openssh_public_key" { 
    content =  tls_private_key.rsa.public_key_openssh
    filename = "${var.project_name}.pub"
  
}

# convert pem2ppk for putty use.
resource "null_resource" "pem2ppk" {
  provisioner "local-exec" {
    command = "./test.sh && puttygen ${var.project_name}.pem -o ${var.project_name}.ppk"
  }
  depends_on = [
    local_file.ssh_openssh_private_key
  ]

}
