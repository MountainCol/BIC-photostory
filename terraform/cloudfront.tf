# Reference existing S3 bucket
data "aws_s3_bucket" "bic_photostory" {
  bucket = "bic-photostory"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = data.aws_s3_bucket.bic_photostory.bucket_regional_domain_name
    origin_id   = "S3-${data.aws_s3_bucket.bic_photostory.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${data.aws_s3_bucket.bic_photostory.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Required restrictions block - this fixes your error
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Required viewer_certificate block
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "BIC-PhotoStory-Distribution"
    Environment = "production"
    Project     = "BIC-PhotoStory"
  }
}

# Origin Access Identity for S3 bucket access
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for BIC PhotoStory S3 bucket"
}

# Outputs
output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.distribution.id
  description = "CloudFront Distribution ID"
}

output "cloudfront_distribution_url" {
  value       = "https://${aws_cloudfront_distribution.distribution.domain_name}"
  description = "CloudFront Distribution URL"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.distribution.domain_name
  description = "CloudFront Domain Name"
}
