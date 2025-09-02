# CI/CD Pipeline for PayNest Document Verifier

# S3 bucket for CodePipeline artifacts
resource "aws_s3_bucket" "paynest_document_verifier_codepipeline" {
  bucket = "paynest-document-verifier-codepipeline-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "paynest_document_verifier_codepipeline" {
  bucket = aws_s3_bucket.paynest_document_verifier_codepipeline.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "paynest_document_verifier_codepipeline" {
  bucket = aws_s3_bucket.paynest_document_verifier_codepipeline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "paynest_document_verifier_codepipeline" {
  bucket = aws_s3_bucket.paynest_document_verifier_codepipeline.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodeBuild project
resource "aws_codebuild_project" "paynest_document_verifier" {
  name         = "paynest-document-verifier-build"
  description  = "Build project for PayNest Document Verifier"
  service_role = aws_iam_role.paynest_document_verifier_codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = local.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = aws_ecr_repository.paynest_document_verifier.repository_url
    }

    environment_variable {
      name  = "APP_RUNNER_SERVICE_ARN"
      value = aws_apprunner_service.paynest_document_verifier.arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = local.common_tags
}

# CodePipeline
resource "aws_codepipeline" "paynest_document_verifier" {
  name     = "paynest-document-verifier-pipeline"
  role_arn = aws_iam_role.paynest_document_verifier_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.paynest_document_verifier_codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.paynest_document_verifier.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "AppRunner"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ServiceArn = aws_apprunner_service.paynest_document_verifier.arn
      }
    }
  }

  tags = local.common_tags
}

