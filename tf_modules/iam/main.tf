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