# 1. The "ID Badge" (Origin Access Control)
resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "resume-oac"
  description                       = "Secure OAC for Resume Website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "resume_cdn" {
  enabled             = true
  # "is_ipv6_enabled" is optional. Deleted.
  default_root_object = "index.html"

  # 1. ORIGIN: Where is the content coming from?
  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_id                = "my-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_oac.id
  }

  # 2. CACHE BEHAVIOR: How should we deliver it?
  # (Console does this automatically, but Terraform needs these rules)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-s3-origin"
    
    # This block is mandatory. It tells CloudFront "Don't use cookies" (Static sites don't need them)
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all" # Simplest setting
  }

  # 3. RESTRICTIONS: Who can see it?
  # (Mandatory block, even if you put "none")
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 4. VIEWER CERTIFICATE: HTTPS settings
  # (Mandatory block)
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}