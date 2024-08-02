variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "app-vpc"
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "mysql_db_port" {
  description = "The port the MySQL database will listen on"
  type        = number
  default     = 3306
}

variable "allowed_cidr_blocks" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.db_identifier))
    error_message = "The db_identifier must be alphanumeric only."
  }
}

variable "allocated_storage" {
  description = "The amount of storage to allocate to the RDS instance"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "The maximum amount of storage to allocate to the RDS instance"
  type        = number
  default     = 100
}

variable "instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

