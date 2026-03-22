provider "aws" {
  region              = "ap-southeast-1"
  allowed_account_ids = [var.aws_account_id]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.37.0"
    }
  }
}

