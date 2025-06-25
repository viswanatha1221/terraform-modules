locals {
  private_host_names = ["web", "db", "ml"]
}
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.windows.id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  key_name    = var.jumpkey
  tags = {
    Name = "BastionHost"
  }
}

resource "aws_instance" "private_host" {
  count                  = length(local.private_host_names)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [var.private_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.db_profile.name
  key_name               = var.postgres_key_name

  tags = {
    Name        = "${var.env}-${var.project}-local.private_host_names[count.index]"
  }
}

resource "aws_volume_attachment" "ebs" {
  device_name = "/dev/sdh"
  depends_on  = [aws_instance.privat_host, aws_ebs_volume.ebs]
  volume_id   = aws_ebs_volume.eds.id
  instance_id = aws_instance.privat_host.id
}

resource "aws_ebs_volume" "ebs" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1
  type              = "gp2"
  tags = {
    Name = "EBSVolume"
  }
}