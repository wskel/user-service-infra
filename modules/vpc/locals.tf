locals {
  common_tags = {
    Project     = var.app_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  tags = merge(local.common_tags, var.tags)
}
