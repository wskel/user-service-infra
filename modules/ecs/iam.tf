#region ECS Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name_prefix = "${var.app_name}-${var.environment}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_fargate_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets_access" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}
#endregion

#region ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name_prefix = "${var.app_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_task_ecr_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_ses_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ses_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_rds_connect" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.rds_connect.arn
}
#endregion

#region Custom IAM Policies
resource "aws_iam_policy" "ecr_access" {
  name        = "${var.app_name}-${var.environment}-ecr-access-policy"
  description = "Policy for accessing ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [
          aws_ecr_repository.app.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_access" {
  name        = "${var.app_name}-${var.environment}-secrets-access-policy"
  description = "Policy for accessing specific secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/${var.app_name}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ses_access" {
  name        = "${var.app_name}-${var.environment}-ses-access-policy"
  description = "Policy for accessing SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail"
        ]
        Resource = var.ses_arns
      }
    ]
  })
}

resource "aws_iam_policy" "rds_connect" {
  name        = "${var.app_name}-${var.environment}-rds-connect-policy"
  description = "Policy for connecting to RDS using IAM authentication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_resource_id}/${var.db_username}"
        ]
      }
    ]
  })
}
#endregion
