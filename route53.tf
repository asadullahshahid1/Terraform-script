# Route 53 Configuration for PayNest Document Verifier

data "aws_route53_zone" "paynest" {
  name         = replace(var.domain_name, "/^[^.]+\\./", "")
  private_zone = false
}

# Route 53 record pointing to CloudFront
resource "aws_route53_record" "paynest_document_verifier" {
  zone_id = data.aws_route53_zone.paynest.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.paynest_document_verifier.domain_name
    zone_id                = aws_cloudfront_distribution.paynest_document_verifier.hosted_zone_id
    evaluate_target_health = false
  }
}

