module "loadbalancer_security_group" {
  source = "../securitygroup"

  name   = "Load Balancer Security Group"
  vpc_id = var.security_group_vpc_id

  ingress_from_port   = 80
  ingress_to_port     = 80
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_protocol    = "tcp"

  egress_from_port   = 80
  egress_to_port     = 80
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_protocol    = "tcp"

}

resource "aws_lb" "my_own_load_balancer" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.subnets             # Replace with your subnet IDs
  enable_deletion_protection = var.deletion_protection # Set to true if you want to enable deletion protection
  security_groups            = var.security_groups     # Attach the security group created above
}

resource "aws_lb_target_group" "my_target_group" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type
}
resource "aws_lb_listener" "my_aws_listener" {
  load_balancer_arn = aws_lb.my_own_load_balancer.arn
  port              = var.listener_port
  protocol          = var.protocol

  default_action {
    type             = var.action_type
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_lb_listener_rule" "lb_listener" {
  listener_arn = aws_lb_listener.my_aws_listener.arn
  priority     = var.listener_priority

  action {
    type             = var.action_type
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


