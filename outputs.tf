output "rds_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.mysql_db.address
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.mysql_db.endpoint
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.mysql_db.port
}

output "rds_db_name" {
  description = "The name of the RDS database"
  value       = aws_db_instance.mysql_db.db_name
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.mysql_db.arn
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_secret_name" {
  description = "The name of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_credentials_secret_version_arn" {
  description = "The version ID of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret_version.db_secret_version.arn
}

output "db_security_group_id" {
  description = "The ID of the security group associated with the RDS instance"
  value       = aws_security_group.rds_mysql_sg.id
}
