# Outputs for PayNest Document Verifier Infrastructure

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.paynest_document_verifier.repository_url
}

output "app_runner_service_url" {
  description = "URL of the App Runner service"
  value       = aws_apprunner_service.paynest_document_verifier.service_url
}

output "cloudfront_distribution_domain" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.paynest_document_verifier.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.paynest_document_verifier.id
}

output "route53_record_name" {
  description = "Route 53 record name"
  value       = aws_route53_record.paynest_document_verifier.name
}

output "secrets_manager_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.paynest_document_verifier.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.paynest_document_verifier.arn
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.paynest_document_verifier.name
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.paynest_document_verifier.name
}
