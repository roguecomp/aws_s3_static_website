provider "aws" {
  alias  = "virginia"
  region = "us-east-1" # acm certificate can only happen in Virginia
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.url
  subject_alternative_names = ["*.${var.url}"]
  validation_method         = "DNS"
  provider                  = aws.virginia

  tags = {
    Name = var.url
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
  provider        = aws.virginia
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.s3_static_website.bucket_domain_name
    origin_id   = aws_s3_bucket.s3_static_website.id
    ## ...
  }
  enabled             = true
  default_root_object = "index.html"

  aliases = [
    var.url, var.www_url
  ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3_static_website.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [
    aws_acm_certificate.cert,
    aws_acm_certificate_validation.cert,
    aws_s3_object.object
  ]
}
