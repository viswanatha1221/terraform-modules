module "vpc" {
  source      = "./vpc"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
}

module "sg" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source  = "./ec2"
  sg_id   = module.sg.sg_id
  subnets = module.vpc.subnet_ids
}

module "my_bucket" {
  source      = ".s3"
  bucket_name = "edms-dev"
}