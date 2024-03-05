#remarks added as variables descriptions
variable "project_name" {
    type = string
    default = "projeks2024"
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
    default = "10.12.0.0/18"
    description = "public subnet cidr block"  
}

variable "eks_subnet1_cidr_block" {
    type = string
    default = "10.12.64.0/18"
    description = "eks subnet1 cidr block"  
}
variable "eks_subnet2_cidr_block" {
    type = string
    default = "10.12.128.0/18"
    description = "eks subnet2 cidr block"  
}

variable "leftover_subnet_cidr_block" {
    type = string
    default = "10.12.192.0/18"
    description = "leftover subnet cidr block"  
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

variable "jenkins_helm_repo" {
    type = string
    default = "https://charts.jenkins.io"
    description = "jenkins helm repo"
  
}

variable "jenkins_helm_repo_name" {
    type = string
    default = "jenkins"
    description = "jenkins helm repo name"
  
}

variable "jenkins_helm_chart" {
    type = string
    default = "jenkins"
    description = "jenkins helm chart name"
  
}

variable "jenkins_namespace" {
    type = string
    default = "jenkins"
    description = "jenkins name space"
  
}

variable "jenkins_version" {
    type = string
    default = "5.0.17"
    description = "jenkins chart version"
}