############################
# vpc - cidr = 10.12.0.0/16
############################
resource "aws_vpc" "project_vpc" {
    cidr_block = "${var.vpc_cidr_block}"
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

####################
# create elastic ip
####################
resource "aws_eip" "eip" {
    domain = "vpc"
    tags = {
        Name = "${var.project_name}-eip"
    }
}

##########################################
# ngw = attach elastic ip to vpc 
##########################################
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.subnet_public.id
    tags = {
        Name = "${var.project_name}-ngw"
    }
    depends_on = [aws_internet_gateway.igw, aws_subnet.subnet_public]
}


 

################################
# subnet-public = 10.12.0.0/17
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
##################################    
# subnet-private = 10.12.128.0/17
##################################
# default route table

resource "aws_subnet" "subnet_private" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "${var.private_subnet_cidr_block}"
    tags = {
      Name = "${var.project_name}-private-subnet"
    }
}

 ###########################################
 # route table creation for private-subnet
  # private-route-table =
   #* 10.12.0.0/16 = local
   #* 0.0.0.0 = ngw
############################################   
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
 
########################################################
    # associate private-route-table to private-subnet
########################################################    
    resource "aws_route_table_association" "private_route_table_association" {
        subnet_id = aws_subnet.subnet_private.id
        route_table_id = aws_route_table.private_route_table.id
    }



