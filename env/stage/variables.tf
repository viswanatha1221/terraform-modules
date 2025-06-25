variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type        = string
}

variable "key_name" {
  description = "The EC2 key pair name to use"
  type        = string
}

variable "jumpkey" {
  description = "The Bastion key pair name"
  type        = string
}

variable "env" {
  description = "Environment name, e.g., dev, stage"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = list(string)
}