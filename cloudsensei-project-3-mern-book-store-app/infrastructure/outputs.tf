output "lb_name" {
  value = aws_lb.this.dns_name
}

output "ecr_repo_id" {
  value = aws_ecr_repository.this.id
}