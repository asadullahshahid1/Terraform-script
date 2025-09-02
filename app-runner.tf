# App Runner Service for PayNest Document Verifier

resource "aws_apprunner_service" "paynest_document_verifier" {
  service_name = "paynest-document-verifier"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          ENVIRONMENT = var.environment
          LOG_LEVEL   = "info"
        }
        runtime_environment_secrets = {
          SECRETS_ARN = aws_secretsmanager_secret.paynest_document_verifier.arn
        }
      }
      image_identifier      = "${aws_ecr_repository.paynest_document_verifier.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
    authentication_configuration {
      access_role_arn = aws_iam_role.paynest_document_verifier_app_runner_access.arn
    }
  }

  instance_configuration {
    cpu               = var.app_runner_cpu
    memory            = var.app_runner_memory
    instance_role_arn = aws_iam_role.paynest_document_verifier_app_runner.arn
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.paynest_document_verifier.arn

  health_check_configuration {
    healthy_threshold   = 1
    interval            = 10
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = local.common_tags
}

# Auto scaling configuration
resource "aws_apprunner_auto_scaling_configuration_version" "paynest_document_verifier" {
  auto_scaling_configuration_name = "paynest-doc-verifier-autoscaling"
  max_concurrency                 = 100
  max_size                        = var.app_runner_max_size
  min_size                        = var.app_runner_min_size

  tags = local.common_tags
}


