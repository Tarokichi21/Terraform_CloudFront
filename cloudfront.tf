# ---------------------------------------------
# CloudFront cache distribution
# ---------------------------------------------
resource "aws_cloudfront_distribution" "cf" {
  enabled         = true
  is_ipv6_enabled = false
  comment         = "cache distribution"
  price_class     = "PriceClass_All"

  origin {
    domain_name = aws_route53_record.route53_record.fqdn
    origin_id   = aws_lb.for_webserver.name

    custom_origin_config {
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      http_port              = 80
      https_port             = 443
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    target_origin_id       = aws_lb.for_webserver.name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 30
    default_ttl            = 60
    max_ttl                = 90
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.id

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  custom_error_response {
  error_code         = 404
  response_page_path = "/static/index.html"
  response_code      = 200
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  aliases = ["www.${var.domain}"]

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn      = aws_acm_certificate.virginia_cert.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac"
  description                       = "OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_route53_record" "route53_cloudfront" {
  zone_id = aws_route53_zone.route53_zone.id
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = true
  }
}