# tf-module-rds

Note: Only supports mysql

```hcl
module "mysql-rds" {
  source = "git::https://github.com/michaeltuszynski/tf-module-rds.git?ref=main"
  project_name = "common_project"
  vpc_id = "abcdef123"
  vpc_cidr_block = "10.0.0.0/16"
  mysql_db_port = 3306
  allowed_cidr_blocks = ["10.0.3.0/24","10.0.4.0/24"]
  db_identifier = "demo" #no special characters-"db" will appended
  allocated_storage = 20
  max_allocated_storage = 100
  instance_class = "db.t3.micro"
}
```

## Outputs

```hcl
output "rds_address" {
  description = "The address of the RDS instance"
  value = aws_db_instance.mysql_db.address
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.mysql_db.endpoint
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value = aws_db_instance.mysql_db.arn
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_secret_name" {
  description = "The name of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}
```
