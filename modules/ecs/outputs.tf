output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "URL of the ECR repository"
}

output "load_balancer_dns_name" {
  value       = aws_lb.app.dns_name
  description = "DNS name of the load balancer"
}

output "load_balancer_zone_id" {
  value       = aws_lb.app.zone_id
  description = "Zone ID of the load balancer"
}

output "load_balancer_arn" {
  value       = aws_lb.app.arn
  description = "ARN of the Application Load Balancer"
}

output "waf_arn" {
  value       = aws_wafv2_web_acl.main.arn
  description = "ARN of the WAF Web ACL"
}

output "jwt_secret_arn" {
  value       = aws_secretsmanager_secret.jwt_secret.arn
  description = "ARN of the JWT secret in Secrets Manager"
}

output "jwt_issuer_arn" {
  value       = aws_secretsmanager_secret.jwt_issuer.arn
  description = "ARN of the JWT issuer secret in Secrets Manager"
}

output "jwt_audience_arn" {
  value       = aws_secretsmanager_secret.jwt_audience.arn
  description = "ARN of the JWT audience secret in Secrets Manager"
}
