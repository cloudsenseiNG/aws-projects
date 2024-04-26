#This creates a load balancer in front of the public subnet which directs the load to the various ecs clusters in the private subnet
resource "aws_lb" "this" {
  name               = "mern-loadbalancer"
  internal           = false
  ip_address_type    = "ipv4" 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id]  
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "this" {
  name     = "mern-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.vpc.id
}
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}