provider "aws" {
  region  = var.region #"us-west-2"# You can choose your preferred region
  #version = "~> 3.0"    # Ensure you are using a compatible provider version
}

###########################################

#Create ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster-${var.env}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {        
        cloud_watch_log_group_name = aws_cloudwatch_log_group.log_group_cluster.name
      }
    }
  }
}

##############################################

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.project_name}-td-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "my-app"
      image     = "nginx" # Example image. Replace with your image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        },
      ]
    },
  ])
}



#Create CloudWatch Log Group - ECS Cluster
resource "aws_cloudwatch_log_group" "log_group_cluster" {
  name              = "${var.project_name}-cluster-${var.env}"
  retention_in_days = var.cw_logs_retention_in_days
}


resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  #cluster         = aws_ecs_cluster.my_cluster.id
  cluster = aws_ecs_cluster.ecs_cluster.id
  #task_definition = aws_ecs_task_definition.my_task.arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet_private.id] # Replace with your subnet IDs
    security_groups  = [aws_security_group.alb_sg_security_group.id]     # Replace with your security group IDs
    assign_public_ip = true
  }
}

##############################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  # assume_role_policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [
  #     {
  #       Action = "sts:AssumeRole"
  #       Principal = {
  #         Service = "ecs-tasks.amazonaws.com"
  #       }
  #       Effect = "Allow"
  #       Sid    = ""
  #     },
  #   ]
  # })
}


#Trust Policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Get ECS Task Exec IAM Policy #V
data "aws_iam_policy" "ecs_exec_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}


#IAM Policy permissions
# resource "aws_iam_policy" "iam_policy" {
#   name = "${var.project_name}-perm-${var.env}"
#   policy = var.permission_iam_policy
# }

#Attach IAM Policies
resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_exec_policy.arn
}

#Create IAM Role
# resource "aws_iam_role" "iam_role" {
#   name               = "${var.project_name}-role-${var.env}"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy" {
#   name       = "ecsTaskExecutionRolePolicy"
#   roles      = [aws_iam_role.ecs_task_execution_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

############################################

