variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "private_subnet_names" {
  type    = list(string)
  default = ["private-subnet-1", "private-subnet-2", "private-subnet-3"]
} 
