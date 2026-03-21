variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID thật của bạn"
}

variable "project_prefix" {
  type    = string
  default = "d"
}

variable "app_port" {
  type    = number
  default = 80
}

variable "common_tags" {
  type = map(string)
  default = {
    Project   = "AIVN-Lab"
    ManagedBy = "Terraform"
  }
}
