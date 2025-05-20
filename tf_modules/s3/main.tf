resource "aws_s3_bucket" "edms" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "edms" {
  bucket                  = aws_s3_bucket.edms.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "edms" {
  bucket = aws_s3_bucket.edms.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.edms.id
}

output "bucket_arn" {
  value = aws_s3_bucket.edms.arn
}