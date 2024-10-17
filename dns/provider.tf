terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68.0"
    }
  }
}

provider "aws" {
  region = local.aws_region

  default_tags {
    tags = local.common_tags
  }
}
