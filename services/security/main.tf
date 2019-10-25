### Security

# ALB Security group
resource "aws_security_group" "lb" {
  name        = var.aws_security_group_name
  description = "controls access to ${var.aws_security_group_name}"
  vpc_id      = var.aws_vpc_main_id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  for_each    = var.container_config
  name        = "${var.aws_security_group_name}-${var.container_config[each.key].name}-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.aws_vpc_main_id

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}