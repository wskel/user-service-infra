variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

# This should match the domain you've registered and set up in Route 53
variable "domain_name" {
  type        = string
  description = "The domain name for the application"
}

# This is obtained after running the DNS subproject Terraform configuration
variable "route53_zone_id" {
  type        = string
  description = "The Route 53 hosted zone ID for the domain"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources into"
  default     = "us-east-1"
}
