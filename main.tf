module "evt-service" {
  source = "./evt/service"

  service_name               = "service1"
  aws_region                 = var.aws_region
  public_subnet              = true
  aws_route53_root_zone_name = "evt.zone"

  service_secrets = {
    secret1 = {
      name = "give_me_a_name"
    }
  }

  container_config = {
    container1 = {
      name             = "image111",
      image            = "nginx:latest",
      port             = "80",
      assign_public_ip = true,
      tags = merge({
        "tag1" = "value1",
        "tag2" = "value2"
      }, var.environment_tags)
    }
    container2 = {
      name             = "image2222",
      image            = "nginx:latest",
      port             = "443",
      assign_public_ip = true,
      tags = merge({
        "tag1" = "value1",
        "tag2" = "value2"
      }, var.environment_tags)
    }

  }


  environment_tags   = var.environment_tags
  aws_vpc_main_id    = var.aws_vpc_main_id
  aws_subnet_public  = var.aws_subnet_public
  aws_subnet_private = var.aws_subnet_private
}
