# ==========================================
# FILE 1: BASTION SECURITY GROUP (HÌNH 61)
# ==========================================
resource "aws_security_group" "bastion_sg" {
  name        = "d-sg-aivnc-basion-host"
  description = "Allow access from internet"
  vpc_id      = aws_vpc.main.id

  # Inbound Rule 1: HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule 2: SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule: All traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "d-sg-aivnc-basion-host" }
}

# ==========================================
# FILE 2: WEB SERVER SECURITY GROUP (HÌNH 62)
# ==========================================
resource "aws_security_group" "web_sg" {
  name        = "d-sg-aivn-webserver"
  description = "Allow access from bastion host"
  vpc_id      = aws_vpc.main.id

  # Inbound Rule 1: SSH (Chỉ từ Bastion)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] 
  }

  # Inbound Rule 2: HTTP (Chỉ từ Bastion)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Outbound Rule: All traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "d-sg-aivn-webserver" }
}
