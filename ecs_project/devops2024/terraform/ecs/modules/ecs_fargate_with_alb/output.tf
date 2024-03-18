output "ecs_target_group_arn" {
  value = aws_lb_target_group.ecs_target_group.arn
  description = "The ARN of the ECS target group"
}