resource "aws_route53_zone" "this" {
  name = local.domain_name
  tags = local.common_tags
}
