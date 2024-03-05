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




#=====================================================================
# IAM
#=====================================================================
# eks IAM Role, Policies : AmazonEKSClusterPolicy, AmazonEKSVPCResourceControlle
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eksclusterrole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        },  
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# IAM role, Policies attachments for eks worker
# Policies : AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role" "eks_worker_role" {
  name = "eksWorkerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
    role       = aws_iam_role.eks_worker_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    role       = aws_iam_role.eks_worker_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
    role       = aws_iam_role.eks_worker_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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
# resource "null_resource" "pem2ppk" {
#   provisioner "local-exec" {
#     command = "./test.sh && puttygen ${var.project_name}.pem -o ${var.project_name}.ppk"
#   }
#   depends_on = [
#     local_file.ssh_openssh_private_key
#   ]

# }
