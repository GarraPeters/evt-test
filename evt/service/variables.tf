variable "aws_region" {
  description = "(Required) This is the AWS region. It must be provided, but it can also be sourced from the AWS_DEFAULT_REGION environment variables, or via a shared credentials file if profile is specified."
}

variable "aws_vpc_cidr_block" {
  description = "(Required) The CIDR block for the VPC."
  type        = string
  default     = "192.168.240.0/20"
}

variable "aws_vpc_tag_name" {
  description = "(Required) The name of the VPC (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = "evt-ephemeral"
}

variable "aws_vpc_subnet_private_cidr_block_newbits" {
  default = "2"
}

variable "aws_vpc_subnet_public_cidr_block_newbits" {
  default = "4"
}

variable "aws_vpc_subnet_public_map_public_ip_on_launch" {
  default = false
}

variable "aws_vpc_subnets_private_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "aws_vpc_subnets_public_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "container_config" {
  description = "Docker image to run in the ECS cluster"
  default     = "nginx:latest"
}

variable "service_name" {
  default = "evt-ephemeral"
}

variable "aws_route53_root_zone_name" {
  default = "evt.zone"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "aws_ecs_task_definition_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "aws_ecs_task_definition_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "aws_cloudwatch_log_group_tag_environment" {
  description = "Cloud logging eviroment"
  default     = "Development"
}

variable "aws_cloudwatch_log_group_tag_application" {
  description = "Cloud logging Application"
  default     = "serviceA"
}

variable "aws_ecs_task_definition_family" {
  description = "ECS task definition family name"
  default     = "app"
}


variable "aws_ecs_service_public_ip" {
  description = "ECS service assign public IP"
  default     = true
}


variable "aws_vpc_main_id" {
  type = string
}

variable "aws_subnet_public" {
  type = list
}

variable "aws_subnet_private" {
  type = list
}

variable "public_subnet" {
}


variable "service_secrets" {

}

variable "environment_tags" {
  type = map
}


