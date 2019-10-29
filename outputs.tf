output "service_output" {
  value = {
    service_hostname = "https://${var.service_name}.${var.aws_route53_root_zone_name}"
    repository_url   = module.cluster.repository_url
    secret_arn       = module.cluster.secret_arn
  }
}
