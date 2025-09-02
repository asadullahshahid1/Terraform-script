# CloudFront Distribution and WAF for PayNest Document Verifier

# WAF Web ACL
resource "aws_wafv2_web_acl" "paynest_document_verifier" {
  name  = "paynest-document-verifier-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Rule to block malicious IPs
  rule {
    name     = "BlockMaliciousIPs"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.paynest_document_verifier_malicious_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockMaliciousIPs"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Core Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "paynestDocumentVerifierWAF"
    sampled_requests_enabled   = true
  }

  tags = local.common_tags
}

# IP Set for malicious IPs
resource "aws_wafv2_ip_set" "paynest_document_verifier_malicious_ips" {
  name               = "paynest-document-verifier-malicious-ips"
  description        = "IP set for malicious IPs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.malicious_ips

  tags = local.common_tags
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "paynest_document_verifier" {
  origin {
    domain_name = replace(aws_apprunner_service.paynest_document_verifier.service_url, "https://", "")
    origin_id   = "paynest-document-verifier-app-runner"

    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 60
      origin_keepalive_timeout = 5
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "PayNest Document Verifier CloudFront Distribution"
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "paynest-document-verifier-app-runner"

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Host"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = aws_wafv2_web_acl.paynest_document_verifier.arn

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.paynest_document_verifier_logs.bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  tags = local.common_tags
}

# S3 bucket for CloudFront logs
resource "aws_s3_bucket" "paynest_document_verifier_logs" {
  bucket = "paynest-document-verifier-cloudfront-logs-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "paynest_document_verifier_logs" {
  bucket = aws_s3_bucket.paynest_document_verifier_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "paynest_document_verifier_logs" {
  bucket = aws_s3_bucket.paynest_document_verifier_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "paynest_document_verifier_logs" {
  bucket = aws_s3_bucket.paynest_document_verifier_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "paynest_document_verifier_logs" {
  bucket = aws_s3_bucket.paynest_document_verifier_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "paynest_document_verifier_logs" {
  bucket = aws_s3_bucket.paynest_document_verifier_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontLogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.paynest_document_verifier_logs.arn}/*"
      }
    ]
  })
}

# Random ID for bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
