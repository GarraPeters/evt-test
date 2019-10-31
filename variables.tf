variable "aws_region" {

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



variable "environment_tags" {
  type = map
}


