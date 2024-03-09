resource "aws_efs_file_system" "wordpress_fs" {
  creation_token  = var.creation_token
  throughput_mode = var.throughput_mode

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }
}

resource "aws_efs_mount_target" "fs_mount_a" {
  file_system_id  = aws_efs_file_system.wordpress_fs.id
  subnet_id       = var.subnet_a
  security_groups = var.security_groups
}

resource "aws_efs_mount_target" "fs_mount_b" {
  file_system_id  = aws_efs_file_system.wordpress_fs.id
  subnet_id       = var.subnet_b
  security_groups = var.security_groups
}