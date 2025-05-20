locals {
  instance_profile_names = [for prefix in var.name_prefix : "${prefix}-instance-profile"]
  iam_role_names         = [for prefix in var.name_prefix : "${prefix}-role"]
  iam_policy_names       = [for prefix in var.name_prefix : "${prefix}-policy"]
}

resource "aws_iam_instance_profile" "default" {
  count = length(var.name_prefix)
  name  = local.instance_profile_names[count.index]
  role  = aws_iam_role.default[0].name
  tags  = var.tags
}

resource "aws_iam_role" "default" {
  count = length(var.name_prefix)
  name  = local.iam_role_names[count.index]
  path  = "/"
  tags  = var.tags

  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy" "main" {
  count = length(var.name_prefix)
  name   = local.iam_policy_names[count.index]
  role   = aws_iam_role.default[0].id
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetEncryptionConfiguration"
    ]

    resources = ["*"]
  }
}