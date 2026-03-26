# outputs.tf
output "rds_endpoint" {
  description = "Địa chỉ Endpoint để ní kết nối vào Database"
  value       = aws_db_instance.mysql_aivn.endpoint
}
