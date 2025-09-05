# Variables for PayNest Document Verifier Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Domain name for the service"
  type        = string
  default     = "verify.paynest.com"
}

variable "github_repository" {
  description = "GitHub repository ID for CodeStar connection"
  type        = string
  default     = "Terraform-Script"
}

variable "github_branch" {
  description = "GitHub branch for deployment"
  type        = string
  default     = "main"
}

variable "app_runner_cpu" {
  description = "App Runner CPU configuration"
  type        = string
  default     = "0.25 vCPU"
}

variable "app_runner_memory" {
  description = "App Runner memory configuration"
  type        = string
  default     = "0.5 GB"
}

variable "app_runner_min_size" {
  description = "Minimum number of App Runner instances"
  type        = number
  default     = 1
}

variable "app_runner_max_size" {
  description = "Maximum number of App Runner instances"
  type        = number
  default     = 10
}

variable "malicious_ips" {
  description = "List of malicious IP addresses to block"
  type        = list(string)
  default = [
    "192.0.2.0/24",
    "203.0.113.0/24"
  ]
}


variable "codestar_connection_arn" {
  description = "ARN of the existing CodeStar connection for GitHub integration"
  type        = string
  default     = "arn:aws:codeconnections:region:account-ID:connection-ID"
}

variable "profile_name" {
  description = "Profile Name"
  type        = string
  default     = "terraform-user"

}
