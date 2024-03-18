variable "alb_listener_arn" {
  type = string
}

variable "alb_listener_rule_conditions" {
  type = list(object({
    field              = string
    header_name        = optional(string)
    values             = list(string)
    query_string_value = optional(string)
    query_string_key   = optional(string)
  }))
}

variable "target_group_arn" {
  type = string
}