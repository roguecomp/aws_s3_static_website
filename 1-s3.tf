provider "aws" {
  region = var.region
}

terraform {

  cloud {
    organization = "vishnukap_learning"

    workspaces {
      name = "s3-website"
    }
  }
}

resource "aws_s3_bucket" "s3_static_website" {
  bucket        = var.www_url
  force_destroy = true

  tags = {
    Name = var.url
  }
}

resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.s3_static_website.id

  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject"
        "Effect" : "Allow"
        "Principal" : "*"
        "Action" : [
          "s3:GetObject",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy"
        ]
        "Resource" : [
          aws_s3_bucket.s3_static_website.arn,
          "${aws_s3_bucket.s3_static_website.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "s3_static_website_pa_block" {
  bucket = aws_s3_bucket.s3_static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_static_website_acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.s3_static_website_pa_block
  ]
  bucket = aws_s3_bucket.s3_static_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "s3_static_website" {
  bucket = aws_s3_bucket.s3_static_website.bucket

  index_document {
    suffix = var.root_html
  }
}

resource "aws_s3_object" "object" {
  bucket       = var.www_url
  key          = var.root_html
  source       = "src/${var.root_html}"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("src/${var.root_html}")

  depends_on = [
    aws_s3_bucket.s3_static_website
  ]
}

resource "aws_s3_object" "favicon" {
  bucket = var.www_url
  key    = var.favicon_path
  source = "src/${var.favicon_path}"
  acl    = "public-read"
  # content_type = "text/html"
  etag = filemd5("src/${var.favicon_path}")

  depends_on = [
    aws_s3_bucket.s3_static_website
  ]
}