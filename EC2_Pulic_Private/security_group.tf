# 1. SG CHO ALB - Tiếp nhận traffic từ Internet
module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "alb-sg"
  description = "Security group cho Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"] # Cho phép ALB đẩy traffic đi mọi nơi trong VPC
}

# 2. SG CHO APP SERVER - Chỉ nhận traffic từ ALB
module "app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "app-server-sg"
  description = "Chỉ cho phép ALB truy cập"
  vpc_id      = module.vpc.vpc_id

  # Cấu hình "Hợp tác tác chiến" (Computed Source)
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp" # App nhận traffic HTTP
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]
}
