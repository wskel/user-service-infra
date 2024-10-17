#region ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"

  tags = local.tags
}
#endregion

#region ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.app_name}-${var.environment}-container"
      image = "${aws_ecr_repository.app.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = concat(
        [for k, v in var.env_config : { name = k, value = tostring(v) }],
        [
          {
            name  = "DATABASE_URL"
            value = "jdbc:postgresql://${var.db_instance_endpoint}/${var.db_instance_name}"
          },
          {
            name  = "DATABASE_USER"
            value = var.db_username
          }
        ]
      )
      secrets = [
        { name = "JWT_SECRET", valueFrom = aws_secretsmanager_secret.jwt_secret.arn },
        { name = "JWT_ISSUER", valueFrom = aws_secretsmanager_secret.jwt_issuer.arn },
        { name = "JWT_AUDIENCE", valueFrom = aws_secretsmanager_secret.jwt_audience.arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.tags
}
#endregion

#region ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2 # Number of tasks to run
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_tasks_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false # tasks will run in private subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.app_name}-${var.environment}-container"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.https]

  tags = local.tags
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4 # Maximum number of tasks
  min_capacity       = 2 # Minimum number of tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = local.tags
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.app_name}-${var.environment}-autoscaling-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0 # Target CPU utilization percentage
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.app_name}-${var.environment}-autoscaling-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0 # Target memory utilization percentage
  }
}
#endregion

#region Application Load Balancer
resource "aws_lb" "app" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = local.tags
}
#endregion

#region ALB Target Group
resource "aws_lb_target_group" "app" {
  name                 = "${var.app_name}-${var.environment}-tg"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30 # seconds

  health_check {
    healthy_threshold   = "3"  # Number of consecutive successful health checks
    interval            = "30" # seconds
    protocol            = "HTTP"
    matcher             = "200" # HTTP status code
    timeout             = "3"   # seconds
    path                = "/health"
    unhealthy_threshold = "2" # Number of consecutive failed health checks
  }

  tags = local.tags
}
#endregion

#region ALB Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.tags
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    path_pattern {
      values = ["/health"]
    }
  }

  tags = local.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = local.tags
}
#endregion

#region CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name_prefix       = "/ecs/${var.app_name}-${var.environment}"
  retention_in_days = 30 # Number of days to retain logs
  tags              = local.tags
}
#endregion

#region ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = "${var.app_name}-repo-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}
#endregion

#region ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep only the 10 most recent images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
#endregion
