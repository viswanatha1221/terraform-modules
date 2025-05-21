output "vpc_id" {
    value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
    value = aws_subnet.subnets.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}