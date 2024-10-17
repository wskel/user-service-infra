locals {
  db_username = replace("${var.app_name}${var.environment}masteruser", "/[^a-zA-Z0-9]/", "")

  common_tags = {
    Project     = var.app_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  tags = merge(local.common_tags, var.tags)
}
