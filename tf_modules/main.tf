module "vpc" {
  source      = "./tf_modules/vpc"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
}

module "sg" {
  source = "./tf_modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source  = "./tf_modules/ec2"
  sg_id   = module.sg.sg_id
  subnets = module.vpc.subnet_ids
}
