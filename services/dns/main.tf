resource "aws_route53_zone" "host_zone" {
  name = var.aws_route53_zone_name
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.host_zone.zone_id
  name    = var.aws_route53_record_zone_name
  type    = "A"

  alias {
    name                   = var.loadblancer_dns
    zone_id                = var.loadblancer_zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "root_domain" {
  name         = var.aws_route53_root_zone_name
}

resource "aws_route53_record" "root_ns_record" {
  allow_overwrite = true
  name            = var.aws_route53_zone_name
  ttl             = 30
  type            = "NS"
  zone_id         = data.aws_route53_zone.root_domain.zone_id

  records = [
    aws_route53_zone.host_zone.name_servers.0,
    aws_route53_zone.host_zone.name_servers.1,
    aws_route53_zone.host_zone.name_servers.2,
    aws_route53_zone.host_zone.name_servers.3,
  ]
}