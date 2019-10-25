output "dns_name" {
  value = aws_alb.main.dns_name
}

output "zone_id" {
  value = aws_alb.main.zone_id
}

output "target_group" {
  value = aws_alb_target_group.app
}


output "aws_alb_main_id" {
  value = aws_alb.main.id
}


