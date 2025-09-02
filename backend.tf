terraform {
  backend "s3" {
    bucket = "tf-state-file-verifier"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}