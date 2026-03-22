module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  intra_subnets   = []

  enable_nat_gateway = true #Private -> internet (Ok) Internet -> Private (Block)
  single_nat_gateway = true
  enable_vpn_gateway = false

  create_database_subnet_group           = false
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false #block db -> internet
  enable_dns_hostnames                   = true # goi db
  enable_dns_support                     = true

  public_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 110
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0" # Có thể thay bằng IP nhà ông cho an toàn
    },
    {
      rule_number = 120
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0" # ĐƯỜNG VỀ: Cực kỳ quan trọng (Ephemeral Ports) thực tế cần cấu hình cái này lai
    }
  ]

  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"

      # ĐƯỜNG VỀ: Cực kỳ quan trọng (Ephemeral Ports) thực tế cần cấu hình cái này lai
    }
  ]



  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
