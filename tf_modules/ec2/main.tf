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

resource "aws_iam_role" "postgresql_role" {
  name = "ec2_postgresql_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "redis_role" {
  name = "ec2_redis_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "postgresql_profile" {
  name = "ec2_postgresql_profile"
  role = aws_iam_role.postgresql_role.name
}

resource "aws_iam_instance_profile" "redis_profile" {
  name = "ec2_redis_profile"
  role = aws_iam_role.redis_role.name
}

# Attach policy to allow read/write to our bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "ec2_s3_access_policy"
  description = "Allow EC2 to access the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        module.s3.bucket_arn,
        "${module.s3.bucket_arn}/*"
      ]
    }]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}