output "vpc_id" {
  value = aws_vpc.wordpress_vpc.id
}

output "public_subnet_a" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b" {
  value = aws_subnet.public_subnet_b.id
}

output "private_subnet_a" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_b" {
  value = aws_subnet.private_subnet_b.id
}

output "private_subnet_c" {
  value = aws_subnet.private_subnet_c.id
}

output "private_subnet_d" {
  value = aws_subnet.private_subnet_d.id
}