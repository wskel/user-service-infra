locals {
  # App Configuration
  app_name = "user-service"

  # Environment configuration
  environment = var.environment

  # AWS Configuration
  aws_region = var.aws_region

  # Domain Configuration
  domain_name = var.domain_name

  # Subdomain to use for custom MAIL FROM domain
  ses_mail_from_subdomain = "mail"

  # IAM Configuration
  ses_iam_user_name = "ses_user"

  # Route53 Configuration
  route53_zone_id = var.route53_zone_id

  # SES Configuration
  ses_allowed_sender_email    = "service@${var.domain_name}"
  ses_verified_receiver_email = "support@${var.domain_name}"
  ses_configuration_set       = "${local.app_name}-${var.environment}-config-set"

  # Email address for receiving DMARC aggregate reports (RUA)
  dmarc_report_email = "dmarc-reports@${var.domain_name}"

  common_tags = {
    Project     = local.app_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
