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

# Attach policy to db role
resource "aws_iam_role_policy_attachment" "ec2_attach_policy" {
  role       = aws_iam_role.db_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}