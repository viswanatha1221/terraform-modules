variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type        = string
  default  = "10.0.0.0/16"
}

variable "postgres_key_name" {
  description = "The EC2 key pair name to use"
  type        = string
  default     = "pd-key-name" # or leave this out to require it
}

variable "redis_key_name" {
  description = "The EC2 key pair name to use"
  type        = string
  default     = "rs-key-name" # or leave this out to require it
}
