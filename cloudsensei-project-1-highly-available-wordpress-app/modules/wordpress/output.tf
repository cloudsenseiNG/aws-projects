output "app_security_group_id" {
  value = module.app_security_group.security_group_id
}

output "app_asg_name" {
  value = aws_autoscaling_group.web_asg.name
}