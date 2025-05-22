resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  tags = {
    Name = "BastionHost"
  }
}

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

resource "aws_instance" "ec2_postgresql" {
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.private_sg_id]
  subnet_id                   = var.private_subnet_ids[0]
  availability_zone           = data.aws_availability_zones.available.names[0]
  iam_instance_profile        = aws_iam_instance_profile.postgresql_profile.name
  key_name                    = var.postgres_key_name   # <-- Add this line
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

resource "aws_iam_role_policy_attachment" "ssm_postgresql" {
  role       = aws_iam_role.postgresql_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_volume_attachment" "ebs_postgresql" {
  device_name = "/dev/sdh"
  depends_on  = [aws_instance.ec2_postgresql, aws_ebs_volume.postgresql]
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
  vpc_security_group_ids      = [var.private_sg_id]
  subnet_id                   = var.private_subnet_ids[1]
  availability_zone           = data.aws_availability_zones.available.names[1]
  iam_instance_profile        = aws_iam_instance_profile.redis_profile.name
  key_name                    = var.redis_key_name   # <-- Add this line
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install epel -y
              yum install -y redis
              systemctl enable redis
              systemctl start redis
              sed -i 's/^bind 127.0.0.1 -::1/#bind 127.0.0.1 -::1/' /etc/redis.conf
              sed -i 's/protected-mode yes/protected-mode no/' /etc/redis.conf
              systemctl restart redis
              EOF

  tags = {
    Name = var.ec2_names[1]
  }
}

resource "aws_iam_role_policy_attachment" "ssm_redis" {
  role       = aws_iam_role.redis_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_volume_attachment" "ebs_redis" {
  device_name = "/dev/sdh"
  depends_on = [aws_instance.ec2_redis, aws_ebs_volume.redis]
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
        var.s3_bucket_arn,
        "${var.s3_bucket_arn}/*"
      ]
    }]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_attach_policy" {
  role       = aws_iam_role.postgresql_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_attach_policy_redis" {
  role       = aws_iam_role.redis_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


























































