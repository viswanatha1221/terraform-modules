output "postgresql_instance_ids" {
  value = aws_instance.db-instance[*].id
}

output "redis_instance_ids" {
  value = aws_instance.db-instance[*].id
}

