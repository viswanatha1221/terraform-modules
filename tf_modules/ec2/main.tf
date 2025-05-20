locals {
  create_instance_profile = var.enabled && try(length(var.instance_profile), 0) == 0
  instance_profile        = local.create_instance_profile ? join("", aws_iam_instance_profile.default[*].name) : var.instance_profile
  eip_enabled             = var.associate_public_ip_address && var.assign_eip_address && var.enabled
  security_group_enabled  = var.enabled && var.sg_id != ""
  public_dns              = local.eip_enabled ? local.public_dns_rendered : join("", aws_instance.db-instance[*].public_dns)
  public_dns_rendered = local.eip_enabled ? format("ec2-%s.%s.amazonaws.com",
    replace(join("", aws_eip.default[*].public_ip), ".", "-"),
    data.aws_region.default.name == "us-east-1" ? "compute-1" : format("%s.compute", data.aws_region.default.name)
  ) : null
  user_data_templated = templatefile("${path.module}/${var.user_data_template}", {
    user_data   = join("\n", var.user_data)
    ssm_enabled = var.ssm_enabled
    ssh_user    = var.ssh_user
  })
}
  
resource "aws_instance" "db-instance" {
  count                       = length(var.instances)
  ami                         = coalesce(var.ami, join("", data.aws_ami.default[*].id))
  instance_type               = var.instance_type
  user_data                   = var.instances[count.index].user_data
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = local.instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = var.subnets[count.index]

  root_block_device {
    encrypted   = var.root_block_device_encrypted
    volume_size = var.root_block_device_volume_size
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device_volume_size > 0 ? [1] : []

    content {
      encrypted             = var.ebs_block_device_encrypted
      volume_size           = var.ebs_block_device_volume_size
      delete_on_termination = var.ebs_delete_on_termination
      device_name           = var.ebs_device_name
      snapshot_id           = var.ebs_snapshot_id
    }
  }

  tags = var.tags
}

resource "aws_eip" "default" {
  count    = local.eip_enabled ? 1 : 0
  instance = join("", aws_instance.db-instance[*].id)
  tags     = var.tags
}