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
          "s3:PutBucketPolicy",
          "s3:PutBucketWebsite",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:DeleteObject"
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

resource "aws_s3_bucket_ownership_controls" "s3_static_website_object_ownership" {
  bucket = aws_s3_bucket.s3_static_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
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

resource "aws_s3_object" "media" {
  for_each = fileset("${path.module}/${var.react_app_path}", "*.svg")

  bucket       = var.www_url
  key          = each.value
  source       = "${path.module}/${var.react_app_path}/${each.value}"
  acl          = "public-read"
  content_type = "image/svg+xml"
  etag         = filemd5("${path.module}/${var.react_app_path}/${each.value}")

  depends_on = [
    aws_s3_bucket.s3_static_website
  ]
}

resource "aws_s3_object" "css" {
  for_each = fileset("${path.module}/${var.react_app_path}", "*.css")

  bucket       = var.www_url
  key          = each.value
  source       = "${path.module}/${var.react_app_path}/${each.value}"
  acl          = "public-read"
  content_type = "text/css"
  etag         = filemd5("${path.module}/${var.react_app_path}/${each.value}")

  depends_on = [
    aws_s3_bucket.s3_static_website
  ]
}

resource "aws_s3_object" "html" {
  for_each = fileset("${path.module}/${var.react_app_path}", "*.html")

  bucket       = var.www_url
  key          = each.value
  source       = "${path.module}/${var.react_app_path}/${each.value}"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("${path.module}/${var.react_app_path}/${each.value}")

  depends_on = [
    aws_s3_bucket.s3_static_website
  ]
}