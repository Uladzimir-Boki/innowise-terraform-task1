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

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${local.name_prefix}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "security_group" {
  name        = "${local.name_prefix}-sg"
  description = "Security group to allow SSH and HTTP access"

  dynamic "ingress" {
    for_each = [80, 22]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-ec2-instance" {
  for_each = var.instance_configs

  ami = data.aws_ami.ubuntu.id

  key_name = aws_key_pair.key_pair.key_name

  vpc_security_group_ids = [aws_security_group.security_group.id]

  user_data = file("${path.module}/user-data.sh")

  instance_type = each.value

  lifecycle {
    ignore_changes = [ user_data ]
  }

  tags = {
    Name = "${local.name_prefix}-${each.key}-ec2"
  }
}

output "tls_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}