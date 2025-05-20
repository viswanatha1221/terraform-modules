resource "aws_instance" "ec2_postgresql" {
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnets[0]
  availability_zone           = data.aws_availability_zones.available.names[0]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable postgresql14
              yum install -y postgresql-server
              postgresql-setup initdb
              systemctl enable postgresql
              systemctl start postgresql
              EOF

  tags = {
    Name = var.ec2_names[0]
  }
}

resource "aws_volume_attachment" "ebs_postgresql" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.postgresql.id
  instance_id = aws_instance.ec2_postgresql.id
}

resource "aws_ebs_volume" "postgresql" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1
}


resource "aws_instance" "ec2_redis" {
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnets[1]
  availability_zone           = data.aws_availability_zones.available.names[1]

  user_data = <<-EOF
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

  tags = {
    Name = var.ec2_names[1]
  }
}

resource "aws_volume_attachment" "ebs_redis" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.redis.id
  instance_id = aws_instance.ec2_redis.id
}

resource "aws_ebs_volume" "redis" {
  availability_zone = data.aws_availability_zones.available.names[1]
  size              = 1
}