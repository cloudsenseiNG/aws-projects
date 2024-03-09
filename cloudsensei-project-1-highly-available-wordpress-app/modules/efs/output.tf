output "fs_security_group_id" {
  value = aws_security_group.fs_security_group.id
}

output "efs_filesystem" {
  value = aws_efs_file_system.wordpress_fs
}

output "efs_id" {
  value = aws_efs_file_system.wordpress_fs.id
}
