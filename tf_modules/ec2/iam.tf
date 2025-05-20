locals {
  instance_profile_name = "${var.name_prefix}-${var.environment}-instance-profile"
  iam_role_name         = "${var.name_prefix}-${var.environment}-role"
  iam_policy_name       = "${var.name_prefix}-${var.environment}-policy"
}

resource "aws_iam_instance_profile" "default" {
  count = var.enabled && local.create_instance_profile ? 1 : 0
  name  = local.instance_profile_name
  role  = aws_iam_role.default[0].name
  tags  = var.tags
}

resource "aws_iam_role" "default" {
  count = var.enabled && local.create_instance_profile ? 1 : 0
  name  = local.iam_role_name
  path  = "/"
  tags  = var.tags

  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy" "main" {
  count  = var.enabled && local.create_instance_profile ? 1 : 0
  name   = local.iam_policy_name
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