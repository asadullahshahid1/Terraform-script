# CloudWatch Logging and Monitoring for PayNest Document Verifier

# CloudWatch Log Group for App Runner
resource "aws_cloudwatch_log_group" "paynest_document_verifier" {
  name              = "/aws/apprunner/paynest-document-verifier"
  retention_in_days = 30

  tags = local.common_tags
}

# CloudWatch Log Group for WAF
resource "aws_cloudwatch_log_group" "paynest_document_verifier_waf" {
  name              = "/aws/wafv2/paynest-document-verifier"
  retention_in_days = 30

  tags = local.common_tags
}


