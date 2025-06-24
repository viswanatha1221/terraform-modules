variable "ec2_names" {
    description = "EC2 names"
    type = list(string)
    default = ["postgresql-node", "redis-node"]
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
}

variable "jumpkey"{
 description=" The Bastion key pair name"
 type = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = [edms]
}