locals {
  env_config = {
    APP_SECURITY_HANDLE_FORWARDED_HEADERS = true
    APP_SECURITY_ENABLE_HSTS              = false # SSL termination at load balancer or reverse proxy
    APP_SECURITY_ENABLE_CORS              = true
    APP_SECURITY_CORS_ALLOWED_HOSTS       = local.domain_name
    RUN_MIGRATIONS                        = true
    DATABASE_MAX_POOL_SIZE                = 10
    SES_ENABLED                           = true
    SES_SOURCE_EMAIL                      = "noreply@${local.domain_name}"
    SES_REGION                            = local.aws_region
    SECRET_STORE_REGION                   = local.aws_region
    SECRET_STORE_PREFIX                   = "${local.environment}/${local.app_name}"
    DATABASE_SCHEMA                       = "${local.app_name}_${local.environment}_schema"
    DATABASE_USE_IAM_AUTH                 = true
    DATABASE_IAM_REGION                   = local.aws_region
  }
}
