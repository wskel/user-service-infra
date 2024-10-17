variable "domain_name" {
  type        = string
  description = "The domain name for the application"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources into"
  default     = "us-east-1"
}
