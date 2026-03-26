provider "aws" {
  region              = var.region
  profile             = "default"
  allowed_account_ids = [var.aws_account_id]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.37.0"
    }
  }
}
