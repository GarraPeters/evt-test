module "security" {
  source = "./services/security"

  aws_security_group_name = "${var.service_name}-alb-security-group"
  container_config        = var.container_config

  aws_vpc_main_id = var.aws_vpc_main_id
}

module "cert_manager" {
  source = "./services/cert_manager"

  network_route53_zone_name = module.dns.zone_name
  network_route53_zone_id   = module.dns.zone_id
}

module "dns" {
  source = "./services/dns"

  aws_route53_zone_name        = "${var.service_name}.${var.aws_route53_root_zone_name}"
  aws_route53_record_zone_name = "${var.service_name}.${var.aws_route53_root_zone_name}"
  aws_route53_root_zone_name   = var.aws_route53_root_zone_name


  loadblancer_dns     = module.loadbalancer.dns_name
  loadblancer_zone_id = module.loadbalancer.zone_id

}

module "loadbalancer" {
  source = "./services/loadbalancer"

  aws_alb_name              = "${var.service_name}-alb"
  aws_alb_target_group_name = "${var.service_name}-alb"

  service_config = var.container_config

  aws_subnets              = var.public_subnet == true ? var.aws_subnet_public : var.aws_subnet_private
  aws_security_group_lb_id = module.security.aws_security_group_lb_id

  aws_vpc_main_id                                        = var.aws_vpc_main_id
  aws_acm_certificate_validation_default_certificate_arn = module.cert_manager.aws_acm_certificate_validation_default_certificate_arn

}

module "cluster" {
  source = "./services/cluster"

  service_secrets                                                   = var.service_secrets
  app_count                                                         = var.app_count
  aws_region                                                        = var.aws_region
  aws_cloudwatch_log_group_name                                     = var.service_name
  aws_cloudwatch_log_group_tag_environment                          = var.aws_cloudwatch_log_group_tag_environment
  aws_cloudwatch_log_group_tag_application                          = var.aws_cloudwatch_log_group_tag_environment
  aws_ecs_task_definition_container_definitions_var_container_image = var.container_config
  aws_ecs_task_definition_cpu                                       = var.aws_ecs_task_definition_cpu
  aws_ecs_task_definition_memory                                    = var.aws_ecs_task_definition_memory
  aws_ecs_task_definition_family                                    = "${var.service_name}-task"
  aws_ecs_cluster_name                                              = "${var.service_name}-cluster"

  aws_security_group_ecs_tasks_id = module.security.aws_security_group_ecs_tasks_id

  aws_subnets      = var.public_subnet == true ? var.aws_subnet_public : var.aws_subnet_private
  target_group_arn = module.loadbalancer.target_group

  aws_alb_main_id = module.loadbalancer.aws_alb_main_id

  aws_acm_certificate_validation_default_certificate_arn = module.cert_manager.aws_acm_certificate_validation_default_certificate_arn
}

