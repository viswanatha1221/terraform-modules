variable "sg_id" {
  description = "SG ID for EC2"
  type = string
}

variable "subnets" {
  description = "Subnets for EC2"
  type = list(string)
}

variable "ec2_names" {
    description = "EC2 names"
    type = list(string)
    default = ["postgresql-node", "redis-node"]
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}