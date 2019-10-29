variable "aws_alb_name" {
  type = string
}

variable "aws_alb_target_group_name" {
  type = string
}

variable "aws_security_group_lb_id" {
  type = string
}

variable "aws_vpc_main_id" {
  type = string
}


variable "aws_subnets" {
  type = list
}

variable "aws_acm_certificate_validation_default_certificate_arn" {
  type = string
}

variable "service_config" {
}

variable "environment_tags" {
  type = map
}

