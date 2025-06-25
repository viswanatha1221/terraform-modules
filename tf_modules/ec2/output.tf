output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_host_names" {
  value = local.private_host_names
}

output "private_host_ids" {
  value = aws_instance.private_host[*].id
}