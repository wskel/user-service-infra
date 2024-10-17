variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for the database"
  type        = string
}

variable "tags" {
  description = "Additional tags to append"
  type        = map(string)
  default     = {}
}
