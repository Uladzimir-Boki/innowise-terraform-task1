locals {
  name_prefix = "${var.project_name}-${var.env}"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my-ec2-instance" {
  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  tags = {
    Name = "${local.name_prefix}-ec2"
  }
}