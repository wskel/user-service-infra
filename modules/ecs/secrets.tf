#region JWT Secrets

# WARNING: Do NOT add the secret value here. The actual JWT secret should be managed
# outside of Terraform for security reasons. Use the AWS CLI or AWS Console to set
# the secret value after the Terraform deployment is complete. Refer to the project
# README for instructions on how to securely set the secret value.
resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "${var.environment}/${var.app_name}/jwt/secret"
  description = "JWT secret for ${var.app_name} in ${var.environment} environment"
  tags        = merge(local.common_tags, var.tags)
}

# JWT Issuer - managed by Terraform
resource "aws_secretsmanager_secret" "jwt_issuer" {
  name_prefix = "${var.environment}/${var.app_name}/jwt/issuer"
  description = "JWT issuer for ${var.app_name} in ${var.environment} environment"
  tags        = merge(local.common_tags, var.tags)
}

resource "aws_secretsmanager_secret_version" "jwt_issuer" {
  secret_id     = aws_secretsmanager_secret.jwt_issuer.id
  secret_string = var.jwt_issuer
}

# JWT Audience - managed by Terraform
resource "aws_secretsmanager_secret" "jwt_audience" {
  name_prefix = "${var.environment}/${var.app_name}/jwt/audience"
  description = "JWT audience for ${var.app_name} in ${var.environment} environment"
  tags        = merge(local.common_tags, var.tags)
}

resource "aws_secretsmanager_secret_version" "jwt_audience" {
  secret_id     = aws_secretsmanager_secret.jwt_audience.id
  secret_string = var.jwt_audience
}
#endregion
