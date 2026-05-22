# ---------------------------------------------
# S3 static bucket
# ---------------------------------------------
resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.project}-${var.environment}-static-contents-terraform"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-static-bucket"
  })
}
# ---------------------------------------------
# Versioning
# ---------------------------------------------
resource "aws_s3_bucket_versioning" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
# ---------------------------------------------
# Public Access Block
# ---------------------------------------------
resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------
# bucket policy
# ---------------------------------------------
resource "aws_s3_bucket_policy" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.website_bucket.json
}

data "aws_iam_policy_document" "website_bucket" {

  statement {
    sid    = "AllowCloudFrontOAC"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cf.arn]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.website_bucket.arn,
      "${aws_s3_bucket.website_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}