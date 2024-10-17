#region modules
module "ses_setup" {
  source                      = "./modules/ses"
  app_name                    = local.app_name
  environment                 = local.environment
  domain_name                 = local.domain_name
  ses_mail_from_subdomain     = local.ses_mail_from_subdomain
  route53_zone_id             = local.route53_zone_id
  ses_iam_user_name           = local.ses_iam_user_name
  ses_allowed_sender_email    = local.ses_allowed_sender_email
  ses_verified_receiver_email = local.ses_verified_receiver_email
  ses_configuration_set       = local.ses_configuration_set
  dmarc_report_email          = local.dmarc_report_email
  tags                        = local.common_tags
}

module "vpc_setup" {
  source                 = "./modules/vpc"
  app_name               = local.app_name
  environment            = local.environment
  domain_name            = local.domain_name
  load_balancer_arn      = module.ecs_setup.load_balancer_arn
  load_balancer_dns_name = module.ecs_setup.load_balancer_dns_name
  load_balancer_zone_id  = module.ecs_setup.load_balancer_zone_id
}

module "ecs_setup" {
  source                      = "./modules/ecs"
  app_name                    = local.app_name
  environment                 = local.environment
  aws_region                  = local.aws_region
  domain_name                 = local.domain_name
  alb_security_group_id       = module.vpc_setup.alb_security_group_id
  ecs_tasks_security_group_id = module.vpc_setup.ecs_tasks_security_group_id
  vpc_id                      = module.vpc_setup.vpc_id
  public_subnet_ids           = module.vpc_setup.public_subnet_ids
  private_subnet_ids          = module.vpc_setup.private_subnet_ids
  env_config                  = local.env_config
  fargate_cpu                 = "256"
  fargate_memory              = "1024"
  jwt_issuer                  = "${local.app_name}-${local.environment}-auth"
  jwt_audience                = "${local.app_name}-${local.environment}-api"
  ses_arns = [
    module.ses_setup.ses_domain_identity_arn,  # receiving
    module.ses_setup.ses_email_identity_arn,   # sending
    module.ses_setup.ses_configuration_set_arn # configuration set
  ]
  acm_certificate_arn  = module.vpc_setup.acm_certificate_arn
  db_username          = module.rds_setup.db_username
  db_instance_endpoint = module.rds_setup.db_instance_endpoint
  db_instance_name     = module.rds_setup.db_instance_name
  db_resource_id       = module.rds_setup.db_resource_id
}

module "rds_setup" {
  source            = "./modules/rds"
  app_name          = local.app_name
  environment       = local.environment
  subnet_ids        = module.vpc_setup.private_subnet_ids
  security_group_id = module.vpc_setup.database_security_group_id
}
#endregion

#region Outputs
output "ses_domain_identity_arn" {
  description = "The ARN of the SES domain identity"
  value       = module.ses_setup.ses_domain_identity_arn
}

output "ses_iam_user_arn" {
  description = "The ARN of the created IAM user"
  value       = module.ses_setup.iam_user_arn
}

output "ses_iam_user_name" {
  description = "The name of the created IAM user"
  value       = module.ses_setup.iam_user_name
}

output "ses_verified_receiver_email" {
  description = "The verified email address for receiving emails"
  value       = module.ses_setup.ses_verified_receiver_email
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecs_setup.ecr_repository_url
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs_setup.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.ecs_setup.load_balancer_zone_id
}

output "application_url" {
  description = "URL of the application"
  value       = module.vpc_setup.application_url
}

output "alb_security_group_id" {
  description = "The ID of the security group for the ALB"
  value       = module.vpc_setup.alb_security_group_id
}

output "ecs_tasks_security_group_id" {
  description = "The ID of the security group for ECS tasks"
  value       = module.vpc_setup.ecs_tasks_security_group_id
}

output "database_security_group_id" {
  description = "The ID of the security group for the database"
  value       = module.vpc_setup.database_security_group_id
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  value       = module.rds_setup.db_instance_endpoint
}

output "db_instance_name" {
  description = "The name of the database"
  value       = module.rds_setup.db_instance_name
}
#endregion
