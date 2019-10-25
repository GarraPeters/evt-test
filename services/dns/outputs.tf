output "zone_id" {
  value = aws_route53_zone.host_zone.zone_id
}

output "zone_name" {
  value = var.aws_route53_zone_name
}