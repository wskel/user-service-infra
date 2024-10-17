resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = local.tags
}

resource "random_id" "snapshot_suffix" {
  byte_length = 4
}

resource "aws_db_instance" "database" {
  identifier                          = "${var.app_name}-${var.environment}-db"
  engine                              = "postgres"
  engine_version                      = "16.3"
  instance_class                      = "db.t4g.micro"
  multi_az                            = true
  allocated_storage                   = 50
  max_allocated_storage               = 200
  storage_type                        = "gp3"
  db_name                             = replace("${var.app_name}${var.environment}db", "/[^a-zA-Z0-9]/", "")
  username                            = local.db_username
  iam_database_authentication_enabled = true
  manage_master_user_password         = true
  master_user_secret_kms_key_id       = aws_kms_key.db_password_key.key_id
  parameter_group_name                = aws_db_parameter_group.enhanced_logging.name

  # Backup configuration
  backup_retention_period = 35            # 35 days
  backup_window           = "07:00-08:00" # 2:00-3:00 AM Eastern Standard Time (UTC-5), 3:00-4:00 AM EDT (UTC-4)

  # Database deletion protection
  deletion_protection = true

  # Set to `false` and provide a `final_snapshot_identifier` to create a final
  # snapshot before destroying the database. This allows for potential data
  # recovery but may slow down destroy operations. Set to `true` for faster
  # destroys, but be aware this will result in permanent data loss.
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.app_name}-${var.environment}-final-snapshot-${random_id.snapshot_suffix.hex}"

  storage_encrypted = true
  kms_key_id        = aws_kms_key.db_encryption_key.arn

  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn
  monitoring_interval                   = 60 # 60 seconds
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = aws_kms_key.db_encryption_key.arn

  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  # Immediately applies configuration changes, but may force a reboot of the database
  apply_immediately = true

  tags = local.tags
}

resource "aws_db_parameter_group" "enhanced_logging" {
  family      = "postgres16"
  name_prefix = "${var.app_name}-${var.environment}-enhanced-logging"

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_disconnections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_checkpoints"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_lock_waits"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "1000" # Log queries that run for 1 second or longer
    apply_method = "immediate"
  }

  parameter {
    name         = "log_temp_files"
    value        = "0" # Log all temporary file usage
    apply_method = "immediate"
  }

  parameter {
    name         = "log_autovacuum_min_duration"
    value        = "0" # Log all autovacuum operations
    apply_method = "immediate"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "pg_stat_statements.track"
    value        = "all"
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}
