#region Network Outputs
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of the private subnets"
}
#endregion

#region Security Group Outputs
output "alb_security_group_id" {
  description = "The ID of the security group for the ALB"
  value       = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  description = "The ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "database_security_group_id" {
  description = "The ID of the security group for the database"
  value       = aws_security_group.database.id
}
#endregion

#region DNS Outputs
output "application_url" {
  value       = "https://${aws_route53_record.app.name}"
  description = "URL of the application"
}
#endregion

#region Certificate Outputs
output "acm_certificate_arn" {
  value       = aws_acm_certificate.main.arn
  description = "ARN of the ACM certificate"
}
#endregion
