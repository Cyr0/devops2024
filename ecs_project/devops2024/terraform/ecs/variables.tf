#remarks added as variables descriptions
variable "env" {
  type = string
  description = "Environment name"
}

variable "project" {
  type = string
  description = "Project name"
}

# variable "workload_domains" {
#   type = set(string)
#   description = "Workload domains"
# }

# variable "acm_certificate_name" {
#   type = string
#   description = "ACM certificate name"
# }

variable "ingress_alb_dns_name" {
  type = string
  description = "ALB DNS name"
}

# variable "vpc_id" {
#   type = string
#   description = "VPC ID"
# }

# variable "web_acl_id" {
#   type = string
#   description = "Web ACL ID"
# }

variable "x_custom_header_value" {
  type = string
  description = "Custom header value"
}

# variable "workload_nlb_name" {
#   type = string
#   description = "NLB name"
# }

variable "cw_logs_retention_in_days" {
  type = number
  description = "CloudWatch Logs retention in days"
}

variable "ecs_definitions" {
  type = map(object({
    service_name = string
    ecs_td_task_memory = string
    ecs_service_desired_count = number
    ecs_td_task_cpu = string
    ecs_container_image = string
    ecs_container_port = number
    health_check_path = string
  }))
}



variable "default_origin_request_policy_id" {
  type = string
  description = "Origin Request Policy ID"
}

variable "default_response_headers_policy_id" {
  type = string
  description = "Response Headers Policy ID"
}


# variable "workload_alb_name" {
#   type = string
#   description = "ALB name"
# }

#==================================



variable "project_name" {
    type = string
    default = ""
    description = "Project Name"
}

variable "region" {
    type = string
    default = ""
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

variable "private_subnet_cidr_block" {
    type = string
    default = "10.12.128.0/18"
    description = "public subnet cidr block"  
}

# variable "leftover_subnet_cidr_block" {
#     type = string
#     default = "10.12.192.0/18"
#     description = "leftover subnet cidr block"  
# }


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

