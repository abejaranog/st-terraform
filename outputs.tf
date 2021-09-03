output "cloudfront_endpoint" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3_website_endpoint" {
  value = aws_s3_bucket.web_bucket.website_endpoint
}