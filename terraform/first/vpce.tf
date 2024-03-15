# Create VPC Endpoint
resource "aws_vpc_endpoint" "vpce" {
  vpc_id             = aws_vpc.project_vpc.id
  service_name       = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type  = "Interface"
  #vpc_endpoint_type  = "Gateway"
  security_group_ids = setunion([aws_security_group.public_security_group.id], [aws_security_group.private_security_group.id])
  subnet_ids         = setunion([aws_subnet.subnet_public.id])

}

data "aws_network_interface" "vpce_eni_ips" {
    for_each = toset(aws_vpc_endpoint.vpce.network_interface_ids)
    id = each.value
    }
  


