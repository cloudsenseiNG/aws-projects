resource "aws_security_group" "this" {
  name        = "loadbalancer_security_group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
  }
}

resource "aws_security_group" "node" {
  name = "node_security_group"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "this" {
  type = "ingress"
  from_port = 5000
  to_port = 5000
  protocol = "tcp"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.this.id
}

