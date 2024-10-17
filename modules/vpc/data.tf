data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

data "aws_availability_zones" "available" {
  state = "available"
}
