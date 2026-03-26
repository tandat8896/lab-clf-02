# --- PROVIDER & NETWORK ---
provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.37.0"
    }
  }
}

resource "aws_default_vpc" "default" {}

# II.2.1. Cấu hình Security Group (Hình 2)
module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "d-sg-aivn-mysql"
  description = "Allow access from Internet"
  vpc_id      = aws_default_vpc.default.id

  ingress_with_cidr_blocks = [
    {
      rule        = "mysql-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "d-sg-aivn-mysql"
  }
}

# II.2.2. Cấu hình RDS - MySQL (Tổng hợp Hình 5 -> 15)
resource "aws_db_instance" "mysql_aivn" {
  # Engine & Identifier
  engine         = "mysql"
  engine_version = "8.0.40"
  identifier     = "d-rds-mysql-aivn"

  # Templates & Instance Class
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az          = false

  # Connectivity (Hình 12)
  availability_zone      = "ap-southeast-1a"
  port                   = 3306
  ca_cert_identifier     = "rds-ca-rsa2048-g1" # Mặc định theo Hình 12
  vpc_security_group_ids = [module.rds_sg.security_group_id]
  publicly_accessible    = true

  # Credentials (Hình 8)
  username = var.rds_username
  password = var.rds_password
  # manage_master_user_password = false

  # Additional Configuration (Hình 14)
  db_name                 = "aivndatabase"
  backup_retention_period = 1
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = true

  # Monitoring (Hình 13)
  performance_insights_enabled = false
  database_insights_mode       = "standard"
  monitoring_interval          = 0

  # Maintenance & Encryption (Hình cuối)
  storage_encrypted          = true
  auto_minor_version_upgrade = true
  deletion_protection        = false

  # Parameters (Optional - bỏ qua nếu không chắc chắn tên group)
  # parameter_group_name = "default.mysql8.0.4"
  # option_group_name  = "default:mysql-8-4"
  delete_automated_backups = true
}
