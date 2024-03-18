############################
# vpc - cidr = 10.12.0.0/16
############################
resource "aws_vpc" "project_vpc" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.project_name}-vpc"
    }
}
######################
# igw = attach to vpc
######################
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.project_vpc.id
    tags = {
      Name = "${var.project_name}-igw"
    }
}

################################
# subnet-public = 10.12.0.0/18
################################
resource "aws_subnet" "subnet_public" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "${var.public_subnet_cidr_block}"

    map_public_ip_on_launch = true

    tags = {
      Name = "${var.project_name}-public-subnet"
    }
    depends_on = [aws_route_table.public_route_table]
}
#########################################
resource "aws_subnet" "subnet_private" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "${var.private_subnet_cidr_block}"

    map_public_ip_on_launch = true

    tags = {
      Name = "${var.project_name}-public-subnet"
    }
    depends_on = [aws_route_table.public_route_table]
}
 #########################################
 # route table creation for public-subnet
 # public-route-table =
   #* 10.12.0.0/16 = local
   #* 0.0.0.0 = igw
##########################################

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

##################################################### 
    # associate public-route-table to public-subnet
#####################################################    
    resource "aws_route_table_association" "public_route_table_association" {
        subnet_id = aws_subnet.subnet_public.id
        route_table_id = aws_route_table.public_route_table.id
    }