output "route53_zone_id" {
  description = "The Zone ID of the created Route 53 hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "The name servers for the created Route 53 hosted zone"
  value       = aws_route53_zone.this.name_servers
}
