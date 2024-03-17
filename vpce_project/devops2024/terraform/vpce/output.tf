# output "vpce_network_interface_ids" {
#   value = aws_vpc_endpoint.vpce.network_interface_ids
# }

#  output "vpce_network_interface_ips" {
#    value = data.aws_network_interface.vpce_eni_ips
#  }

# output "vpce_eni_private_ips" {
#   value = { for eni_id, eni in aws_network_interface.vpce_eni_ips : eni_id => eni.private_ips }
# }



# output "vpce_eni_private_ips" {
#   value = { for eni_id, eni in data.aws_network_interface.vpce_eni_ips : eni_id => eni.private_ips }
# }

# output "vpce_eni_private_ips" {
#   value = { for eni_id, eni in data.aws_network_interface.vpce_eni_ips : eni_id => eni.id }
# }
# output "vpce_eni_private_ips_list" {
#   value = flatten([for  eni_id , eni in data.aws_network_interface.vpce_eni_ips : eni.private_ips])
# }


# output "vpce_network_interface_dns_entry" {
#   value = aws_vpc_endpoint.vpce.dns_entry
# }

output "vpce_eni_private_ips_list" {
  value = flatten([for  eni_id , eni in data.aws_network_interface.vpce_eni_ips : eni.private_ips])
}