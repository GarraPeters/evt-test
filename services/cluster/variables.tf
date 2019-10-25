variable "app_count" {
  type        = string
}

variable "aws_region" {
  type        = string
}

variable "aws_cloudwatch_log_group_name" {
  type        = string
}

variable "aws_cloudwatch_log_group_tag_environment" {
  type        = string
}

variable "aws_cloudwatch_log_group_tag_application" {
  type        = string
}

variable "aws_ecs_task_definition_container_definitions_var_container_image" {
}

variable "aws_ecs_task_definition_cpu" {
  type        = string
}

variable "aws_ecs_task_definition_memory" {
  type        = string
}

variable "aws_ecs_cluster_name" {
  type        = string
}

variable "aws_ecs_task_definition_family" {
  type        = string
}


variable "aws_security_group_ecs_tasks_id" {
}

variable "aws_subnets" {
  type        = list
}

variable "target_group_arn" {
}

variable "aws_alb_main_id" {
  type        = string
}


variable "aws_acm_certificate_validation_default_certificate_arn" {
  type        = string
}


variable "service_secrets" {
  
}
