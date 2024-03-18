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


resource "aws_security_group" "outbound-all_security_group" {
    name = "${var.project_name}-outbound-all"
    description = "public security group for bastion"
    vpc_id =  aws_vpc.project_vpc.id

    egress {
        from_port = "${var.no_protocol_port}"
        to_port = "${var.no_protocol_port}"
        protocol = "${var.no_protocol}"
        cidr_blocks = ["${var.internet_cidr_block}"]
    }

    tags = {
        Name = "${var.project_name}-outbound-all"
    }
}

resource "aws_security_group" "alb_sg_security_group" {
    name = "${var.project_name}-alb_sg_security_group"
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
