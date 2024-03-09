output "target_group_arn" {
  value = aws_lb_target_group.my_target_group.arn
}

output "loadbalancer_security_group_id" {
  value = module.loadbalancer_security_group.security_group_id
}

output "loadbalancer_dns" {
  value = aws_lb.my_own_load_balancer.dns_name
}