# certificates
resource "aws_acm_certificate" "default" {
  domain_name       = var.network_route53_zone_name
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  name    = aws_acm_certificate.default.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.default.domain_validation_options[0].resource_record_type
  zone_id = var.network_route53_zone_id
  records = [aws_acm_certificate.default.domain_validation_options[0].resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn
  validation_record_fqdns = [
    aws_route53_record.validation.fqdn,
  ]
}