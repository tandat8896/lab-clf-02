# 2. BASTION HOST (EC2 Public)
resource "aws_instance" "bastion" {
  ami                         = "ami-xxxxxx" # [GIẢ ĐỊNH: ID AMI của Amazon Linux 2]
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags                        = { Name = "d-vpc-aivn-bastion" }
}

# 3. WEB SERVER (EC2 Private)
resource "aws_instance" "web" {
  ami                    = "ami-xxxxxx"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_1.id
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags                   = { Name = "d-vpc-aivn-web" }
}
