#region General Variables
variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}
#endregion

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "The domain name for SES and Route 53"
  type        = string
}

variable "ses_mail_from_subdomain" {
  description = "Subdomain to use for custom MAIL FROM domain"
  type        = string
}

variable "ses_iam_user_name" {
  description = "The name of the IAM user for SES access"
  type        = string
}

variable "ses_allowed_sender_email" {
  description = "The email address allowed to send emails via SES"
  type        = string
}

variable "ses_verified_receiver_email" {
  description = "The email address verified to receive emails via SES"
  type        = string
}

variable "ses_configuration_set" {
  description = "The name of the SES configuration set to use"
  type        = string
}

variable "dmarc_report_email" {
  description = "The email address to receive DMARC reports"
  type        = string
}

variable "route53_zone_id" {
  description = "The Zone ID of the Route 53 hosted zone"
  type        = string
}
