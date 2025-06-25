vpc_cidr          =  "10.1.0.0/16"
key_name          = "stage_key"
jumpkey           = "stage_jumpkey"
env               = "stage"
project           = "edms"
bucket_name       = "edms-stage-2025"
public_subnet_cidr  = ["10.1.1.0/24"]
private_subnet_cidr = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
