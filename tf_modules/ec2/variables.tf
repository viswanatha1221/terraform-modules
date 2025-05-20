variable "sg_id" {
  description = "SG ID for EC2"
  type = string
}

variable "subnets" {
  description = "Subnets for EC2"
  type = list(string)
}

variable "instances" {
  type = list(object({
    name          = string
    instance_type = string
    user_data     = string
  }))
  default = [
    {
      name          = "postgres"
      instance_type = "t2.micro"
      user_data     = <<-EOF
        #!/bin/bash
        yum update -y
        amazon-linux-extras enable postgresql14
        yum install -y postgresql-server
        postgresql-setup initdb
        systemctl enable postgresql
        systemctl start postgresql
      EOF
    },
    {
      name          = "redis"
      instance_type = "t2.micro"
      user_data     = <<-EOF
        #!/bin/bash
        yum update -y
        amazon-linux-extras install epel -y
        yum install -y redis
        systemctl enable redis
        systemctl start redis
        sed -i 's/^bind 127.0.0.1 -::1/#bind 127.0.0.1 -::1/' /etc/redis/redis.conf
        sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
        systemctl restart redis
      EOF
    }
  ]
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 DNS Zone ID"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Bastion instance type"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "user_data" {
  type        = list(string)
  default     = []
  description = "User data content. Will be ignored if `user_data_base64` is set"
}

variable "user_data_base64" {
  type        = string
  description = "The Base64-encoded user data to provide when launching the instances. If this is set then `user_data` will not be used."
  default     = ""
}

variable "key_name" {
  type        = string
  default     = ""
  description = "Key name"
}

variable "ssh_user" {
  type        = string
  description = "Default SSH user for this AMI. e.g. `ec2-user` for Amazon Linux and `ubuntu` for Ubuntu systems"
  default     = "ec2-user"
}

variable "root_block_device_encrypted" {
  type        = bool
  default     = true
  description = "Whether to encrypt the root block device"
}

variable "root_block_device_volume_size" {
  type        = number
  default     = 8
  description = "The volume size (in GiB) to provision for the root block device. It cannot be smaller than the AMI it refers to."
}

variable "disable_api_termination" {
  type        = bool
  description = "Enable EC2 Instance Termination Protection"
  default     = false
}

variable "monitoring" {
  type        = bool
  description = "Launched EC2 instance will have detailed monitoring enabled"
  default     = true
}

variable "metadata_http_endpoint_enabled" {
  type        = bool
  default     = true
  description = "Whether the metadata service is available"
}

variable "metadata_http_put_response_hop_limit" {
  type        = number
  default     = 1
  description = "The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests."
}

variable "metadata_http_tokens_required" {
  type        = bool
  default     = true
  description = "Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Whether to associate a public IP to the instance."
}

variable "assign_eip_address" {
  type        = bool
  description = "Assign an Elastic IP address to the instance"
  default     = true
}

variable "host_name" {
  type        = string
  default     = "bastion"
  description = "The Bastion hostname created in Route53"
}

variable "user_data_template" {
  type        = string
  default     = "user_data_bootstrap.sh"
  description = "User Data template to use for provisioning EC2 Bastion Host"
}

variable "ami_filter" {
  description = "List of maps used to create the AMI filter for the action runner AMI."
  type        = map(list(string))

  default = {
    name = ["amzn2-ami-hvm-2.*-x86_64-ebs"]
  }
}

variable "ami_owners" {
  description = "The list of owners used to select the AMI of action runner instances."
  type        = list(string)
  default     = ["amazon"]
}

variable "ami" {
  type        = string
  description = "AMI to use for the instance. Setting this will ignore `ami_filter` and `ami_owners`."
  default     = null
}

variable "ssm_enabled" {
  description = "Enable SSM Agent on Host."
  type        = bool
  default     = true
}

variable "ebs_block_device_encrypted" {
  type        = bool
  default     = true
  description = "Whether to encrypt the EBS block device"
}

variable "ebs_block_device_volume_size" {
  type        = number
  default     = 0
  description = "The volume size (in GiB) to provision for the EBS block device. Creation skipped if size is 0"
}

variable "ebs_delete_on_termination" {
  type        = bool
  default     = true
  description = "Whether the EBS volume should be destroyed on instance termination"
}

variable "ebs_device_name" {
  type        = string
  default     = "/dev/sdh"
  description = "The name of the EBS block device to mount on the instance"
}

variable "ebs_snapshot_id" {
  type        = string
  default     = ""
  description = "The snapshot id to use for the EBS block device"
}

variable "instance_profile" {
  type        = string
  description = "A pre-defined profile to attach to the instance (default is to build our own)"
  default     = ""
}

variable "enabled" {
  description = "Enable or disable resource creation"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "name_prefix" {
  type        = list(string)
  default     = ["postgres", "redis"]
  description = "List of name prefixes for resources"
}