#terraform aws requierment
# on providers.tf

# aws terraform provider
# on providers.tf

# vpc - cidr = 10.12.0.0/16
resource "aws_vpc" "project_vpc" {
    cidr_block = "${var.vpc_cidr_block}"
    tags = {
        Name = "${var.project_name}-vpc"
    }
}

# igw = attach to vpc
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.project_vpc.id
    tags = {
      Name = "${var.project_name}-igw"
    }
}

# create elastic ip # need to create eip
resource "aws_eip" "eip" {
    domain = "vpc"
    tags = {
        Name = "${var.project_name}-eip"
    }
}

# ngw = attach to vpc? attach elastic ip
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.subnet_public.id
    tags = {
        Name = "${var.project_name}-ngw"
    }

    depends_on = [aws_internet_gateway.igw, aws_subnet.subnet_public]
}


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


# subnet-public = 10.12.0.0/17
resource "aws_subnet" "subnet_public" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "${var.public_subnet_cidr_block}"

    map_public_ip_on_launch = true

    tags = {
      Name = "${var.project_name}-public-subnet"
    }
    depends_on = [aws_route_table.public_route_table]
}
 # route table creation for public-subnet
 # public-route-table =
   #* 10.12.0.0/16 = local
   #* 0.0.0.0 = igw

 resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.project_vpc.id

    route {
        cidr_block = aws_vpc.project_vpc.cidr_block
        gateway_id = "${var.local_gw}"
    }
 
     route {
        cidr_block = "${var.internet_cidr_block}"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "${var.project_name}-public-route-table"
    }
 }
 
    # associate public-route-table to public-subnet
    resource "aws_route_table_association" "public_route_table_association" {
        subnet_id = aws_subnet.subnet_public.id
        route_table_id = aws_route_table.public_route_table.id
    }
# subnet-private = 10.12.128.0/17
# default route table
resource "aws_subnet" "subnet_private" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "${var.private_subnet_cidr_block}"
    tags = {
      Name = "${var.project_name}-private-subnet"
    }
}

 # route table creation for private-subnet
  # private-route-table =
   #* 10.12.0.0/16 = local
   #* 0.0.0.0 = ngw
 resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.project_vpc.id

    route {
        cidr_block = aws_vpc.project_vpc.cidr_block
        gateway_id = "${var.local_gw}"
    }
 
     route {
        cidr_block = "${var.internet_cidr_block}"
        gateway_id = aws_nat_gateway.ngw.id
    }
    tags = {
      Name = "${var.project_name}-private_route_table"
    }
 }
 
    # associate private-route-table to private-subnet
    resource "aws_route_table_association" "private_route_table_association" {
        subnet_id = aws_subnet.subnet_private.id
        route_table_id = aws_route_table.private_route_table.id
    }

# ec2 ami filtering
# on data.tf

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

# public-ec2 instance - subnet public, security group public
# public-ec2 instance - user-data
#sudo mkdir /efs/
#sudo dnf install -y amazon-efs-utils python3-pip
#pip3 install botocore
##sudo mount -t efs ${aws_efs_file_system.efs.id}:/ /efs
#echo '${aws_efs_file_system.efs.id}:/ /efs efs defaults,_netdev,nofail 0 0' >> /etc/fstab
#mount -a

# mount efs to public-ec2
# download ssh key and index.html from s3 to efs share
# chmod ~/.ssh/test.pem
# install wget curl

# rsync index.html from public ec2 to private ec2
 # on private ec2 install 
  # minikube => jenkins

# from public wget / curl to private ec2 on jenkins port > log
# rsync log from ec2 private to ec2 public efs share
# upload log to s3
resource "aws_instance" "ec2_public" {
    ami                    = data.aws_ami.amazon_linux.id
    instance_type          = "${var.ec2_instance_type}"
    subnet_id              = aws_subnet.subnet_public.id
    vpc_security_group_ids = [aws_security_group.public_security_group.id]
    key_name               = "${var.private_key_name}"
    iam_instance_profile   = aws_iam_instance_profile.ec2_storage_full_access.name
    depends_on             = [ aws_iam_role.ec2_storage_role, aws_instance.ec2_private ]

    tags = {
      Name = "${var.project_name}-ec2_public"
    }
}

# private ec2 instance - subnet private , security group private

resource "aws_instance" "ec2_private" {
    ami                    = data.aws_ami.amazon_linux.id
    instance_type          = "${var.ec2_instance_type}"
    subnet_id              = aws_subnet.subnet_private.id
    vpc_security_group_ids = [aws_security_group.private_security_group.id]
    key_name               = "${var.private_key_name}"
    iam_instance_profile   = aws_iam_instance_profile.ec2_storage_full_access.name
    user_data              = <<-EOF
                                #!/bin/bash
                                dnf update -y
                                CURRENT_DATE=$(date "+%d-%m-%Y-%H-%M")
                                export BUCKET_NAME="${aws_s3_bucket.s3_bucket.bucket}"
                                export OBJECT_KEY='files'
                                export EFS_DIR=/efs
                                export EFS_FILE=efs.test
                                export LOG_DIR=/tmp
                                export LOG_FILE=efs.log
                                sudo mkdir $EFS_DIR/
                                sudo dnf install -y amazon-efs-utils python3-pip
                                sudo pip3 install botocore cryptography
                                pip3 install botocore cryptography
                                echo '${aws_efs_file_system.efs.id}:/ $EFS_DIR efs defaults,_netdev,nofail 0 0' >> /etc/fstab
                                mount -a
                                sudo echo $CURRENT_DATE > $EFS_DIR/$EFS_FILE
                                ls -lha $EFS_DIR/ > $LOG_DIR/$LOG_FILE
                                aws s3 cp $EFS_DIR/$EFS_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$EFS_FILE 
                                aws s3 cp $LOG_DIR/$LOG_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$LOG_FILE
                                echo "aws s3 cp $EFS_DIR/$EFS_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$EFS_FILE" >> /tmp/test.log
                                echo "aws s3 cp $LOG_DIR/$LOG_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$LOG_FILE" >> /tmp/test.log
                                EOF
    depends_on              = [ aws_iam_role.ec2_storage_role ]
        tags                = {
                                Name = "${var.project_name}-ec2_private"
        }
}




# storage
# create efs for mounting

resource "aws_efs_file_system" "efs" {
    creation_token = "${var.project_name}-efs"
    tags = {
        Name = "${var.project_name}-efs"
    }  
}
resource "aws_efs_mount_target" "efs_mount" {
    file_system_id = aws_efs_file_system.efs.id
    subnet_id = aws_subnet.subnet_private.id
    security_groups = [ aws_security_group.private_efs_security_group.id ]
    depends_on = [ aws_efs_file_system.efs ]
}

resource "aws_efs_access_point" "efs_access_point" {
    file_system_id = aws_efs_file_system.efs.id
    depends_on = [ aws_efs_file_system.efs ]
}
  
# create s3 and upload key and index.html to s3

resource "random_string" "random_str" {
    length = 15
    special = false
    upper = false
}

# resource "random_integer" "random_num" {
#     min = 10000000
#     max = 99999999
# }

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "${var.project_name}-${random_string.random_str.result}"
    force_destroy = true
}

# resource "aws_s3_bucket_object" "upload_script" {
#   bucket = aws_s3_bucket.s3_bucket.bucket
#   key    = "upload.sh"  # This is the path/key where the file will be stored in the bucket
#   source = "${path.module}/files/upload.sh"  # Path to the local file you want to upload
#   acl    = "private"
# }