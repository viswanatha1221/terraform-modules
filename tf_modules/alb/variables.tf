variable "vpc_id" {
  description = "VPC ID for Security Group"
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_sg_id" {
  type = string
}