terraform {
  backend "s3" {
    bucket         = "01929810-289b-71b6-b4e1-f1252fcef840"
    key            = "user-service-infra/dev/dns/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "01929810-289b-71b6-b4e1-f1252fcef840-locks"
  }
}

module "this" {
  source      = "./../../"
  domain_name = var.domain_name
  aws_region  = var.aws_region
  environment = "dev"
}
