output "postgresql_instance_ids" {
  value = aws_instance.ec2_postgresql[*].id
}

output "redis_instance_ids" {
  value = aws_instance.ec2_redis[*].id
}

