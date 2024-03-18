# ami which is amazon linux 2023 , hvm type, x64
data "aws_ami" "amazon_linux" {
    most_recent = true

    filter {
        name = "name"
        values = ["al2023-ami-2023*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }

}

# #Get outbound Security Group
# data "aws_security_group" "outbound_sg" {
#   #provider = aws.workload
#   name     = "outbound-all"
# }

# #Get ALB Security Group
# data "aws_security_group" "alb_sg" {
#   #provider = aws.workload
#     filter {
#     name   = "group-name"
#     values = ["*alb*"]
#   }
# }

#Get workload app subnets
data "aws_subnets" "app_subnets" {
  #provider = aws.workload
  filter {
    name   = "availability-zone"
    values = toset(local.env_to_azs[var.env])
  }
  filter {
    name   = "tag:Name"
    values = ["*workload-app-subnet*"]
  }
}

#Get workload data subnets
data "aws_subnets" "data_subnets" {
  #provider = aws.workload
  filter {
    name   = "availability-zone"
    values = toset(local.env_to_azs[var.env])
  }
  filter {
    name   = "tag:Name"
    values = ["*workload-data-subnet*"]
  }
}

# #Get workload ALB
# data "aws_lb" "alb" {
#   #provider = aws.workload
#   name     = var.workload_alb_name
# }

#Get workload ALB HTTPS Listener
# data "aws_lb_listener" "alb_listener" {
#   #provider = aws.workload
#   load_balancer_arn = data.aws_lb.alb.arn
#   port              = 443
# }
