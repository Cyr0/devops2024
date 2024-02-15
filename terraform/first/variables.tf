#remarks added as variables descriptions
variable "project_name" {
    type = string
    default = "proj2024"
    description = "Project Name"
}

variable "region" {
    type = string
    default = "eu-west-1"
    description = "aws region"
}

variable "private_key_name" {
    type = string
    default = "test"
    description = "private ssh key to attach to ec2 instances"
}

variable "ec2_instance_type" {
    type = string
    default = "t2.micro"
    description = "ec2 instances type"
}

variable "vpc_cidr_block" {
    type = string
    default = "10.12.0.0/16"
    description = "vpc cidr block"  
}

variable "public_subnet_cidr_block" {
    type = string
    default = "10.12.0.0/17"
    description = "public subnet cidr block"  
}

variable "private_subnet_cidr_block" {
    type = string
    default = "10.12.128.0/17"
    description = "private subnet cidr block"  
}

variable "internet_cidr_block" {
    type = string
    default = "0.0.0.0/0"
    description = "internet cidr block"  
}

variable "local_ip_cidr_block" {
    type = string
    default = "5.29.128.74/32"
    description = "local ip cidr block"  
}

variable "local_gw" {
    type = string
    default = "local"
    description = "local getway"

}
variable "ssh_port" {
    type = number
    default = 22
    description = "ssh port"
}

variable "efs_port" {
    type = number
    default = 2049
    description = "efs port"
}

variable "no_protocol" {
    type = number
    default = -1
    description = "no protocol for egress any to any"
}

variable "no_protocol_port" {
    type = number
    default = 0
    description = "no protocol port"
}