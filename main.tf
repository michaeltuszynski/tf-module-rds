## Secrets for DB
resource "random_integer" "password_length" {
  min = 8
  max = 16
}

resource "random_password" "db_password" {
  length  = random_integer.password_length.result
  special = false
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-db-credentials-${random_string.suffix.result}"
  description = "DB credentials for the ${var.project_name} project"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "root"
    password = random_password.db_password.result
  })
}

resource "aws_security_group" "rds_mysql_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-rds-sg"
  description = "Security group for the ${var.project_name} RDS"

  ingress {
    from_port   = var.mysql_db_port
    to_port     = var.mysql_db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "${var.project_name}-db-port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.allowed_cidr_blocks

  tags = merge(
    {
      Name = "rds-subnet-group"
    },
    var.tags
  )
}

# create iam role for enhanced monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

# create iam policy attachment for enhanced monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring_policy_attachment" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

locals {
  db_name = "${var.db_identifier}db"
}

resource "aws_db_instance" "mysql_db" {
  identifier                          = "${var.project_name}-${var.db_identifier}-${random_string.suffix.result}"
  allocated_storage                   = var.allocated_storage
  max_allocated_storage               = var.max_allocated_storage
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring_role.arn
  storage_type                        = "gp3"
  engine                              = "mysql"
  engine_version                      = "8.0.35"
  instance_class                      = var.instance_class
  db_name                             = local.db_name
  parameter_group_name                = "default.mysql8.0"
  skip_final_snapshot                 = true
  vpc_security_group_ids              = ["${aws_security_group.rds_mysql_sg.id}"]
  db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible                 = true
  ca_cert_identifier                  = "rds-ca-rsa2048-g1"
  allow_major_version_upgrade         = true
  auto_minor_version_upgrade          = true
  storage_encrypted                   = true
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # Pointing to the secrets manager for credentials
  username = jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)["password"]

  # Backup settings
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  multi_az = var.multi_az

  tags = var.tags
}
