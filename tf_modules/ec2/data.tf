data "aws_region" "default" {}

data "aws_ami" "default" {
  count = module.this.enabled && var.ami == null ? 1 : 0

  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter
    content {
      name   = filter.key
      values = filter.value
    }
  }

  owners = var.ami_owners
}