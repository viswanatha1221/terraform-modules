terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66.0"
    }
  }
  backend "s3" {
    bucket = "terraform-backend-ed-s3"
    key    = "test/terraform.tfstate"
    region = "us-east-2"
  }
}
provider "aws" {
  region  = "us-west-1"
  #profile = "terraform-user"
}