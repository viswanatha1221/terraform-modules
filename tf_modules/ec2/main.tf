locals {
  private_host_names = ["web", "db", "ml"]
}
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.windows.id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_ids
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  key_name    = "${var.env}_jumpkey"
  tags = {
    Name = "BastionHost"
  }
}

resource "aws_instance" "private_host" {
  count                  = length(local.private_host_names)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[count.index]
  associate_public_ip_address = false
  vpc_security_group_ids = [var.private_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.db_profile.name
  key_name               = "${var.env}_key"

  tags = {
    Name        = "${var.env}-${var.project}-local.private_host_names[count.index]"
  }
}

resource "aws_volume_attachment" "ebs" {
  count       = length(local.private_host_names)
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.private_host[count.index].id
  }

resource "aws_ebs_volume" "ebs" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1
  type              = "gp2"
  tags = {
    Name = "EBSVolume"
  }
}

#bation role and profile
resource "aws_iam_role" "bastion_role" {
  name = "ec2_bastion_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "ec2_bastion_profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_bastion" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#db role and profile
resource "aws_iam_role" "db_role" {
  name = "ec2_db_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "db_profile" {
  name = "ec2_db_profile"
  role = aws_iam_role.db_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_db" {
  role       = aws_iam_role.db_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}