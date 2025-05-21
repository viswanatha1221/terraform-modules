variable "ec2_names" {
    description = "EC2 names"
    type = list(string)
    default = ["postgresql-node", "redis-node"]
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}

variable "bastion_sg_id" {
  type = string
}

variable "private_sg_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "postgres_key_name" {
  description = "The EC2 key pair name"
  type        = string
  default     = "pd-key-name"
}

variable "redis_key_name" {
  description = "The EC2 key pair name"
  type        = string
  default     = "rs-key-name"
}

