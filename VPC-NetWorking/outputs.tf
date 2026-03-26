output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "IP Công cộng của trạm trung chuyển Bastion"
}

output "web_private_ip" {
  value       = aws_instance.web.private_ip
  description = "IP Nội bộ của Web Server (Vùng kín)"
}


# # Đẩy key lên Bastion
# scp -i d-vpc-aivn-key.pem d-vpc-aivn-key.pem ec2-user@<BASTION_PUBLIC_IP>:~/
#
# # SSH vào Bastion
# ssh -i d-vpc-aivn-key.pem ec2-user@<BASTION_PUBLIC_IP>
#
# # Từ Bastion SSH sang Web (Sau khi đã vào Bastion)
# ssh -i d-vpc-aivn-key.pem ec2-user@<WEB_PRIVATE_IP>
