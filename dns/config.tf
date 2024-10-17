locals {
  # AWS Configuration
  aws_region = var.aws_region

  # Domain Configuration
  domain_name = var.domain_name

  # Additional configurations
  environment = var.environment
  project     = "user-service-dns"

  # Tags
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
  }
}
