
# ==========================================================
# 1. TRUY VẤN DỮ LIỆU (DATA SOURCES)
# ==========================================================
data "aws_vpc" "default" { default = true }

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amzn_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ==========================================================
# 2. LƯU TRỮ STATE (S3 BACKEND BOOTSTRAP)
# ==========================================================
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "aivn-terraform-state-storage" 
  force_destroy = true 
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration { status = "Enabled" }
}

# 3. CHÌA KHÓA SSH (SSH KEY PAIR)
# ==========================================================
# ==========================================================
resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vinh_ssh_key" {
  key_name   = "${var.project_prefix}-webserver-key"
  public_key = tls_private_key.lab_key.public_key_openssh
}

resource "local_file" "ssh_key_file" {
  content         = tls_private_key.lab_key.private_key_pem
  filename        = "${path.module}/${var.project_prefix}-webserver-key.pem"
  file_permission = "0400"
}

# ==========================================================
# 4. NHÓM BẢO MẬT (SECURITY GROUPS)
# ==========================================================

# --- 4.1 SG CHO LOAD BALANCER (ALB) ---
resource "aws_security_group" "alb_sg" {
  name   = "${var.project_prefix}-sg-alb"
  vpc_id = data.aws_vpc.default.id
  tags   = { Name = "${var.project_prefix}-sg-alb" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# --- 4.2 SG CHO WEB SERVER ---
resource "aws_security_group" "web_sv_sg" {
  name   = "${var.project_prefix}-sg-websv"
  vpc_id = data.aws_vpc.default.id
  tags   = { Name = "${var.project_prefix}-sg-websv" }
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.web_sv_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_all_out" {
  security_group_id = aws_security_group.web_sv_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ==========================================================
# 5. MÁY CHỦ (COMPUTE: LAUNCH TEMPLATE & ASG)
# ==========================================================

resource "aws_launch_template" "web_lt" {
  name          = "${var.project_prefix}-lt-webserver"
  image_id      = data.aws_ami.amzn_linux_2023.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.vinh_ssh_key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sv_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "Welcome to a webserver: $(hostname -f)" > /var/www/html/index.html
  EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_prefix}-asg-webserver"
  vpc_zone_identifier = data.aws_subnets.default.ids
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}
