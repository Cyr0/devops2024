variable "project_name" {
  type = string
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "vpc_id" {
  type = string
}

variable "permission_iam_policy" {
  type        = string
  description = "JSON string of the permissions"
}

variable "ecs_td_task_cpu" {
  type = string
}

variable "ecs_td_task_memory" {
  type = string
}

variable "cw_logs_retention_in_days" {
  type        = number
  description = "CloudWatch log group retention , enter 0 for never expired"
  default     = 14
}

variable "ecs_container_log_group_name" {
  type = string
}

variable "ecs_td_container_definitions" {
  type = string
}

variable "workload_subnets_ids" {
  type = set(string)
  default = []
}

variable "ecs_service_desired_count" {
  type = number
}

variable "sg_ingress_rules" {
  type = set(object({
    from_port        = number
    to_port          = number
    protocol         = string
    security_groups  = set(string)
    description      = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    self             = bool
  }))
  default = []
}

variable "sg_egress_rules" {
  type = set(object({
    from_port        = number
    to_port          = number
    protocol         = string
    security_groups  = set(string)
    description      = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    self             = bool
  }))
  default = []
}

variable "security_group_ids" {
  type        = set(string)
  description = "Add more Security Groups to ECS Service"
  default     = []
}

variable "ecs_container_port" {
  type = number
}

variable "tg_health_check" {
  type = map(object({
    enabled             = optional(bool)
    path                = optional(string)
    port                = optional(number)
    protocol            = optional(string)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    timeout             = optional(number)
    interval            = optional(number)
    matcher             = optional(string)
  }))
  default = {}
}

variable "alb_tg_stickiness" {
  type = map(object({
    type            = string
    enabled         = optional(bool)
    cookie_duration = optional(number)
    cookie_name     = optional(string)
  }))
  default = {}
}
