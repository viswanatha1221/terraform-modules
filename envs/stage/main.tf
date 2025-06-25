module "vpc" {
  source      = "../../tf_modules/vpc"
  vpc_cidr    = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "sg" {
  source = "../../tf_modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source             = "../../tf_modules/ec2"
  project            = var.project
  env                = var.env
  bastion_sg_id      = module.sg.bastion_sg_id
  private_sg_id      = module.sg.private_sg_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  postgres_key_name  = var.postgres_key_name
  jumpkey            = var.jumpkey
}

module "s3" {
  source      = "../../tf_modules/s3"
  bucket_name = var.bucket_name
}