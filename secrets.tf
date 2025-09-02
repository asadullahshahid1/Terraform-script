# AWS Secrets Manager for PayNest Document Verifier

resource "aws_secretsmanager_secret" "paynest_document_verifier" {
  name                    = "secrets"
  description             = "Secrets for PayNest Document Verifier service"
  recovery_window_in_days = 7

  tags = local.common_tags
}


resource "aws_secretsmanager_secret_version" "paynest_document_verifier" {
  secret_id = aws_secretsmanager_secret.paynest_document_verifier.id
  secret_string = jsonencode({
    DOCUMENT_VERIFICATION_API_KEY = "verification-api-key"
    ENCRYPTION_KEY                = "encryption-key"
    AWS_ACCESS_KEY_ID             = "aws-access-key"
    AWS_SECRET_ACCESS_KEY         = "aws-secret-key"

  })
}

# IAM policy for App Runner to access secrets
resource "aws_iam_policy" "paynest_document_verifier_secrets_access" {
  name        = "paynest-document-verifier-secrets-access"
  description = "Policy for App Runner to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.paynest_document_verifier.arn
      }
    ]
  })

  tags = local.common_tags
}

# KMS key for encrypting secrets
resource "aws_kms_key" "paynest_document_verifier_secrets" {
  description             = "KMS key for PayNest Document Verifier secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.common_tags
}

resource "aws_kms_alias" "paynest_document_verifier_secrets" {
  name          = "alias/paynest-document-verifier-secrets"
  target_key_id = aws_kms_key.paynest_document_verifier_secrets.key_id
}
