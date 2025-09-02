# IAM Roles and Policies for PayNest Document Verifier

# App Runner instance role
resource "aws_iam_role" "paynest_document_verifier_app_runner" {
  name = "paynest-document-verifier-app-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach secrets access policy to App Runner role
resource "aws_iam_role_policy_attachment" "paynest_document_verifier_secrets" {
  role       = aws_iam_role.paynest_document_verifier_app_runner.name
  policy_arn = aws_iam_policy.paynest_document_verifier_secrets_access.arn
}

# App Runner access role for ECR
resource "aws_iam_role" "paynest_document_verifier_app_runner_access" {
  name = "paynest-document-verifier-app-runner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy for App Runner to access ECR
resource "aws_iam_policy" "paynest_document_verifier_ecr_access" {
  name        = "paynest-document-verifier-ecr-access"
  description = "Policy for App Runner to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

# Attach ECR access policy to App Runner access role
resource "aws_iam_role_policy_attachment" "paynest_document_verifier_ecr" {
  role       = aws_iam_role.paynest_document_verifier_app_runner_access.name
  policy_arn = aws_iam_policy.paynest_document_verifier_ecr_access.arn
}

# CodeBuild service role
resource "aws_iam_role" "paynest_document_verifier_codebuild" {
  name = "paynest-document-verifier-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# CodeBuild policy
resource "aws_iam_policy" "paynest_document_verifier_codebuild" {
  name        = "paynest-document-verifier-codebuild-policy"
  description = "Policy for CodeBuild to build and push to ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.paynest_document_verifier_codepipeline.arn}/*"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# Attach CodeBuild policy to CodeBuild role
resource "aws_iam_role_policy_attachment" "paynest_document_verifier_codebuild" {
  role       = aws_iam_role.paynest_document_verifier_codebuild.name
  policy_arn = aws_iam_policy.paynest_document_verifier_codebuild.arn
}

# CodePipeline service role
resource "aws_iam_role" "paynest_document_verifier_codepipeline" {
  name = "paynest-document-verifier-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# CodePipeline policy
resource "aws_iam_policy" "paynest_document_verifier_codepipeline" {
  name        = "paynest-document-verifier-codepipeline-policy"
  description = "Policy for CodePipeline to manage the pipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.paynest_document_verifier_codepipeline.arn,
          "${aws_s3_bucket.paynest_document_verifier_codepipeline.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.paynest_document_verifier.arn
      },
      {
        Effect = "Allow"
        Action = [
          "apprunner:StartDeployment"
        ]
        Resource = aws_apprunner_service.paynest_document_verifier.arn
      }
    ]
  })

  tags = local.common_tags
}

# Attach CodePipeline policy to CodePipeline role
resource "aws_iam_role_policy_attachment" "paynest_document_verifier_codepipeline" {
  role       = aws_iam_role.paynest_document_verifier_codepipeline.name
  policy_arn = aws_iam_policy.paynest_document_verifier_codepipeline.arn
}
