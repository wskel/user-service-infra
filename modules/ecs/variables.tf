#region General Variables
variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
}
#endregion

#region Network Variables
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "ecs_tasks_security_group_id" {
  description = "ID of the security group for ECS tasks"
  type        = string
}
#endregion

#region Fargate Variables
variable "fargate_cpu" {
  description = "Fargate task CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = string
}

variable "fargate_memory" {
  description = "Fargate task memory to provision (in MiB)"
  type        = string
}
#endregion

#region Environmental Config Variables
variable "env_config" {
  description = "Environment-specific configuration"
  type        = map(any)
}
#endregion

#region RDS Variables
variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  type        = string
}

variable "db_instance_name" {
  description = "The name of the database"
  type        = string
}

variable "db_resource_id" {
  description = "The resource ID of the RDS instance"
  type        = string
}
#endregion

#region Domain and Certificate Variables
variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}
#endregion

#region JWT Variables
variable "jwt_issuer" {
  description = "The issuer claim for JWT tokens"
  type        = string
}

variable "jwt_audience" {
  description = "The audience claim for JWT tokens"
  type        = string
}
#endregion

#region SES Variables
variable "ses_arns" {
  description = "ARNs of the SES identities to use for sending emails"
  type        = list(string)
}
#endregion

variable "tags" {
  description = "Additional tags to append"
  type        = map(string)
  default     = {}
}
