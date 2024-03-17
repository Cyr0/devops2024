
output "vpce_eni_ips" {
 value = flatten([for  eni_id , eni in data.aws_network_interface.vpce_eni_ips : eni.private_ips]) 
 
}

