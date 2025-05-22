module "vpc" {
  source      = "./vpc"
  vpc_cidr    = var.vpc_cidr
}

module "sg" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source  = "./ec2"
  bastion_sg_id        = module.sg.bastion_sg_id
  private_sg_id        = module.sg.private_sg_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  s3_bucket_arn        = module.s3.bucket_arn
  postgres_key_name    = var.postgres_key_name
  redis_key_name       = var.redis_key_name
  jumpkey = var.jumpkey
}

module "s3" {
  source      = "./s3"
  bucket_name = "edms-dev-2025"
}
