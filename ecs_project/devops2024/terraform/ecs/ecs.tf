module "create_ecs" {
  source = "./modules/ecs_fargate_with_alb"

  for_each = var.ecs_definitions

#   providers = {
#     aws = aws.workload
#   }

  env                   = var.env
  permission_iam_policy = file("${path.module}/ecs_permissions_policy.json")
  project_name          = "${var.project}-${each.value.service_name}"
  vpc_id                = aws_vpc.project_vpc.id

  //workload_subnets_ids  = data.aws_subnets.app_subnets.ids
  workload_subnets_ids = ["subnet-0223280f18177439b", "subnet-0e98cadc34522a8f5"]

  cw_logs_retention_in_days = var.cw_logs_retention_in_days

  ecs_td_task_cpu           = each.value.ecs_td_task_cpu
  ecs_td_task_memory        = each.value.ecs_td_task_memory
  ecs_container_port        = each.value.ecs_container_port
  ecs_service_desired_count = each.value.ecs_service_desired_count

  ecs_container_log_group_name = "${var.project}-${each.value.service_name}-${var.env}"

  tg_health_check = {
    "a" = {
      enabled             = true
      path                = each.value.health_check_path
      port                = each.value.ecs_container_port
      protocol            = "HTTP"
      healthy_threshold   = 5
      unhealthy_threshold = 2
      timeout             = 15
      interval            = 20
      matcher             = "200"
    }
  }

  ecs_td_container_definitions = jsonencode([
    {
      name      = "${var.project}-${each.value.service_name}-${var.env}"
      image     = "${each.value.ecs_container_image}"
      cpu       = 0
      essential = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.project}-${each.value.service_name}-${var.env}"
          awslogs-region        = "il-central-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = each.value.ecs_container_port
          hostPort      = each.value.ecs_container_port
          protocol      = "tcp"
        }
      ]

      "environment" : [ #TODO:CHANGE
        //{ "name" : "ASPNETCORE_ENVIRONMENT", "value" : "${local.env_to_dotnet_env[var.env]}" }
      ]

      "secrets" : [ #TODO:CHANGE
        //{ "name" : "WORDPRESS_DB_PASSWORD", "valueFrom" : "${module.create-secretmanager-store.secret-manager-arn}:${var.aws_site_name}-${var.aws_env_resource_prefix}-db-password::" }
      ]
    }
  ])

  sg_ingress_rules = [{
    from_port       = each.value.ecs_container_port
    to_port         = each.value.ecs_container_port
    protocol        = "tcp"
    #security_groups = [data.aws_security_group.alb_sg.id]
    security_groups = [aws_security_group.alb_sg_security_group.id]
   


    description      = ""
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    self             = false
  }]

  #security_group_ids = [data.aws_security_group.outbound_sg.id]
  security_group_ids = [aws_security_group.outbound-all_security_group.id]
}

# module "ecs_alb_listener_rule" {
#   source   = "./modules/alb_listener_rule"
#   for_each = module.create_ecs
#   providers = {
#     aws = aws.workload
#   }
#   alb_listener_arn = data.aws_lb_listener.alb_listener.arn
#   target_group_arn = each.value.ecs_target_group_arn

#   alb_listener_rule_conditions = [{
#     field  = "host_header",
#     values = tolist(var.workload_domains)
#     },
#     {
#       field  = "path_pattern",
#       values = ["/*"]
#   }] #TODO:CHANGE
# }

# #Create Lambda
# module "create_lambda" {
#   source = "modules/lambda"
#   providers = {
#     aws = aws.workload
#   }

#   env          = var.env
#   project_name = var.project


#   lambda_package_type = "" #Set to Zip or Image

#   ###ZIP###
#   lambda_file_path = ".zip"
#   lambda_runtime   = "dotnet6"
#   ###ZIP###

#   ###IMAGE###
#   lambda_image        = ""
#   lambda_image_config = {}
#   ###IMAGE###

#   subnets_ids = data.aws_subnets.app_subnets.ids

#   vpc_id = var.vpc_id

#   cw_logs_retention_in_days = var.cw_logs_retention_in_days

#   environment_variables = {
#      #TODO: Add ENV
#   }

#   permission_iam_policy = file("${path.module}/lambda_permissions_policy.json")

#   security_group_ids = [data.aws_security_group.outbound_sg.id]

#   sg_ingress_rules = [] #Change


# }

# S3 - x2
# module "create_buckets" {
#   source = "./modules/s3_vpce"
#   providers = {
#     aws = aws.workload
#   }

#   env     = var.env
#   vpc_id  = var.vpc_id
#   domains = var.workload_domains

#   security_group_ids = [data.aws_security_group.outbound_sg.id]
#   vpce_sg_ingress_rules = [{
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     security_groups = []

#     description      = ""
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     self             = false
#   }]
#   data_subnets_ids = data.aws_subnets.data_subnets.ids
# }

# TODO: Add S3 TG to ALB Listener

# API Gateway - x3

# CF - x2
# module "create_cf_dist" {
#   source = "modules/cf_dist"
#   providers = {
#     aws = aws.shared-networking-us
#   }

#   for_each = module.create_buckets.s3_bucket_names

#   origin_domain_name        = var.ingress_alb_dns_name
#   acm_certificate_name      = var.acm_certificate_name
#   cf_alternate_domain_names = [each.value]
#   web_acl_id                = var.web_acl_id

#   custom_headers = {
#     "X-Custom-Header" = {
#       value = var.x_custom_header_value
#     },
#     "x-apigw-api-id" = {
#       value = #Change with APIGW ID
#     }
#   }

#   default_cache_behavior = {
#     "a" = {
#       allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
#       cached_methods             = ["GET", "HEAD"]
#       compress                   = true
#       cache_policy_id            = #Change
#       origin_request_policy_id   = var.default_origin_request_policy_id
#       response_headers_policy_id = var.default_response_headers_policy_id
#       viewer_protocol_policy     = "redirect-to-https"
#     }
#   }

#   custom_origin_config = {
#     "a" = {
#       origin_protocol_policy = "https-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#       http_port              = 80
#       https_port             = 443
#     }
#   }

#   geo_restriction = {
#     "whitelist" = {
#       locations = ["IL"]
#     }
#   }

# }


# Create Ingress ALB Listener & Target Group for workload NLB Ips
# module "ingress" {
#   source = "modules/ingress_tg_alb_listener_rule"
#   providers = {
#     aws = aws.ingress
#   }
#   ingress_alb_name  = "ingress-alb"
#   tg_name           = "${var.project}-tg-${var.env}"
#   workload_nlb_dns_name = data.aws_lb.nlb.dns_name
#   workload_domains  = var.workload_domains
# }





# #DB
