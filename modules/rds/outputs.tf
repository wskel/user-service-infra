output "db_username" {
  description = "The username for the database"
  value       = local.db_username
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.database.endpoint
}

output "db_instance_name" {
  description = "The name of the database"
  value       = aws_db_instance.database.db_name
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.database.id
}

output "db_resource_id" {
  description = "The resource ID of the RDS instance"
  value       = aws_db_instance.database.resource_id
}

output "db_master_user_secret_arn" {
  description = "The ARN of the secret containing the master user credentials"
  value       = aws_db_instance.database.master_user_secret[0].secret_arn
}

output "db_master_user_secret_kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the RDS master user secret"
  value       = aws_db_instance.database.master_user_secret[0].kms_key_id
}
