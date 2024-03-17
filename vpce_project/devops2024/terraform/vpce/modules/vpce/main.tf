# Create VPC Endpoint
resource "aws_vpc_endpoint" "vpce" {
  vpc_id             = var.vpc_id
  service_name       = var.service_name
  vpc_endpoint_type  = var.vpc_endpoint_type
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

}

# data "aws_network_interface" "vpce_eni_ips" {
#     for_each = toset(aws_vpc_endpoint.vpce.network_interface_ids)
#     id = each.value
# }
  


#### continue from here = https://chat.openai.com/c/0c06a8aa-aa29-432c-94fe-137636c96b76