# output "vpce_eni_private_ips_list" {
#   value = flatten([for , eni in data.aws_network_interface.vpce_eni_ips : eni.private_ips])
# }

# output "vpce_eni_private_ips_list" {
#   value = flatten([for  eni_id , eni in data.aws_network_interface.vpce_eni_ips : eni.private_ips])
# }

# output "vpce_eni_private_ips_list" {
#   #value = flatten([for _, eni in data.aws_network_interface.vpce_eni_ips : eni.private_ips])
#   value = flatten([for _, eni in  {
#     value = ""
#   } : eni.private_ips])
# }

output "network_interface_ids" {
  value = aws_vpc_endpoint.vpce.network_interface_ids
  description = "The network interface IDs associated with the VPC Endpoint."
}