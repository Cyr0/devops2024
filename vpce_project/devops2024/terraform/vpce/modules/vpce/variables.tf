variable "vpc_id" {
  description = "The ID of the VPC where the endpoint will be created."
}

variable "service_name" {
  description = "The service name for the VPC Endpoint."
}

variable "vpc_endpoint_type" {
  description = "The VPC Endpoint type."
  default     = "Interface"
}

variable "security_group_ids" {
  description = "List of security group IDs associated with the VPC Endpoint."
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs where the VPC Endpoint will be created."
  type        = list(string)
}

