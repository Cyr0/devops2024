terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }


  dynamic "condition" {
    for_each = { for i in var.alb_listener_rule_conditions : i.field => i if i.field == "host_header" }
    content {
      host_header {
        values = condition.value["values"]
      }
    }
  }

  dynamic "condition" {
    for_each = { for i in var.alb_listener_rule_conditions : i.field => i if i.field == "path_pattern" }
    content {
      path_pattern {
        values = condition.value["values"]
      }
    }
  }

  dynamic "condition" {
    for_each = { for i in var.alb_listener_rule_conditions : i.field => i if i.field == "http_header" }
    content {
      http_header {
        http_header_name = condition.value["header_name"]
        values           = condition.value["values"]
      }
    }
  }

  dynamic "condition" {
    for_each = { for i in var.alb_listener_rule_conditions : i.field => i if i.field == "http_request_method" }
    content {
      http_request_method {
        values = condition.value["values"]
      }
    }
  }

  dynamic "condition" {
    for_each = { for i in var.alb_listener_rule_conditions : i.field => i if i.field == "query_string" }
    content {
      query_string {
        key   = condition.value["query_string_key"]
        value = condition.value["query_string_value"]
      }
    }
  }

}
