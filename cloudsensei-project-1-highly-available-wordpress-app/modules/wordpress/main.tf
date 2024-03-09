module "app_security_group" {
  source = "../securitygroup"

  name   = "App Security Group"
  vpc_id = var.security_group_vpc_id

  ingress_from_port   = 80
  ingress_to_port     = 80
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_protocol    = "tcp"

  egress_from_port   = 0
  egress_to_port     = 65535
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_protocol    = "tcp"

}

resource "aws_launch_template" "instance_template" {
  name_prefix   = var.name_prefix
  image_id      = var.image_id
  instance_type = var.instance_type
  user_data     = var.user_data
  tags = {
    Name = "wordpress-instances"
  }
  iam_instance_profile {
    arn = var.iam_arn
  }
  vpc_security_group_ids = var.vpc_security_group_ids
  private_dns_name_options {
    hostname_type = "ip-name"
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = var.asg_name
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  target_group_arns   = var.target_group_arns
  vpc_zone_identifier = var.vpc_zone_identifier
  launch_template {
    id      = aws_launch_template.instance_template.id
    version = var.template_version
  }
}


