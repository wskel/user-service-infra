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

#region Domain Variables
variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}
#endregion

#region Load Balancer Variables
variable "load_balancer_arn" {
  description = "ARN of the load balancer"
  type        = string
}

variable "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  type        = string
}

variable "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  type        = string
}
#endregion

#region VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
#endregion

variable "tags" {
  description = "Additional tags to append"
  type        = map(string)
  default     = {}
}
