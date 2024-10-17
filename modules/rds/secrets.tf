resource "aws_kms_key" "db_encryption_key" {
  description             = "KMS key for encrypting RDS database and its associated secrets for ${var.app_name} in ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_key" "db_password_key" {
  description             = "KMS key specifically for encrypting the RDS database password for ${var.app_name} in ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "random_id" "key_alias_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "db_encryption_alias" {
  name          = "alias/${var.app_name}-${var.environment}-db-encryption-${random_id.key_alias_suffix.hex}"
  target_key_id = aws_kms_key.db_encryption_key.key_id
}

resource "aws_kms_alias" "db_password_alias" {
  name          = "alias/${var.app_name}-${var.environment}-db-password-${random_id.key_alias_suffix.hex}"
  target_key_id = aws_kms_key.db_password_key.key_id
}
