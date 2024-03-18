#Trust Policy #V
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

# Get ECS Task Exec IAM Policy
data "aws_iam_policy" "ecs_exec_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

#IAM Policy permissions
resource "aws_iam_policy" "iam_policy" {
  name = "${var.project_name}-perm-${var.env}"
  policy = var.permission_iam_policy
}

#Create IAM Role
resource "aws_iam_role" "iam_role" {
  name               = "${var.project_name}-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#Attach IAM Policies
resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = data.aws_iam_policy.ecs_exec_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_policy_attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-ecs-sg-${var.env}"
  description = "${var.project_name}-ecs-sg"
  vpc_id      = var.vpc_id


  ingress = var.sg_ingress_rules
  egress  = var.sg_egress_rules


  tags = {
    Name = "${var.project_name}-ecs-sg-${var.env}"
  }
}

#Create ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.project_name}-td-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_td_task_cpu
  memory                   = var.ecs_td_task_memory
  execution_role_arn       = aws_iam_role.iam_role.arn
  task_role_arn            = aws_iam_role.iam_role.arn
  container_definitions    = var.ecs_td_container_definitions
}

#Create CloudWatch Log Group - ECS Cluster
resource "aws_cloudwatch_log_group" "log_group_cluster" {
  name              = "${var.project_name}-cluster-${var.env}"
  retention_in_days = var.cw_logs_retention_in_days
}

#Create CloudWatch Log Group - ECS Task Definition
resource "aws_cloudwatch_log_group" "log_group_task" {
  name              = var.ecs_container_log_group_name
  retention_in_days = var.cw_logs_retention_in_days
}

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


# Create ECS Cluster Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
}

#Create Target Group
resource "aws_lb_target_group" "ecs_target_group" {
  #name        = "${var.project_name}-alb-tg-${var.env}"
  name        = "${var.project_name}-atg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  dynamic "stickiness" {
    for_each = var.alb_tg_stickiness
    content {
      type            = stickiness.value["type"]
      cookie_name     = stickiness.value["cookie_name"]
      cookie_duration = stickiness.value["cookie_duration"]
      enabled         = stickiness.value["enabled"]
    }
  }

  dynamic "health_check" {
    for_each = var.tg_health_check
    content {
      enabled             = health_check.value["enabled"]
      path                = health_check.value["path"]
      port                = health_check.value["port"]
      protocol            = health_check.value["protocol"]
      healthy_threshold   = health_check.value["healthy_threshold"]
      unhealthy_threshold = health_check.value["unhealthy_threshold"]
      timeout             = health_check.value["timeout"]
      interval            = health_check.value["interval"]
      matcher             = health_check.value["matcher"]
    }
  }

}

#Create ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project_name}-service-${var.env}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.ecs_service_desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  network_configuration {
    subnets          = var.workload_subnets_ids
    security_groups  = setunion(toset([aws_security_group.ecs_sg.id]), var.security_group_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "${var.project_name}-${var.env}"
    container_port   = var.ecs_container_port
  }
}
