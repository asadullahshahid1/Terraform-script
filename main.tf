# PayNest Document Verifier Infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.profile_name

  default_tags {
    tags = {
      Project     = "paynest-document-verifier"
      Environment = var.environment
      ManagedBy   = "terraform"

    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values for common configurations
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  common_tags = {
    Project     = "paynest-document-verifier"
    Environment = var.environment
    ManagedBy   = "terraform"

  }
}
