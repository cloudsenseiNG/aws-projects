data "aws_availability_zones" "availability_zones" {
  state = "available"
}

data "aws_ami" "amazon_linux_2_latest" {
  owners = ["amazon"]

  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

