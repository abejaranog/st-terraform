resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_bucket.bucket_domain_name
    origin_id   = var.bucket_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_web_bucket.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.bucket_name
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.no-cache.id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.bucket_name
    min_ttl                = 1800
    default_ttl            = 1800
    max_ttl                = 1800
    viewer_protocol_policy = "https-only"
    path_pattern           = "/images/*"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/404.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_cloudfront_cache_policy" "no-cache" {
  name = "CachingDisabled"
}

resource "aws_cloudfront_origin_access_identity" "s3_web_bucket" {
}