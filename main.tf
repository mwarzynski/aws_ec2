provider "aws" {}

# We need the AWS AMI (Amazon Machine ID) to set up our EC2 instance.
# Images become different as they are being upgraaded. We would like to use the latest version.
# For this purpose I defined data source being `aws_ami` which provides ID of the Xenial Ubuntu image.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Allow access over SSH.
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myip}/32"]
  }
}

# Allow access over HTTP.
resource "aws_security_group" "allow_http" {
  name        = "allow-http"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Allow all outbound traffic (over all protocols).
resource "aws_security_group" "allow_all_outbound" {
  name        = "allow-all-outbound"
  description = "Allow all outbound traffic"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resource of our RSA public key.
# Allows to gain access over SSH to the EC2 instance.
resource "aws_key_pair" "ssh" {
  key_name = "${var.name}-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Define the EC2 resource.
# Use AMI (Amazon Machine ID) from the datasource defined above.
resource "aws_instance" "instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name = aws_key_pair.ssh.key_name

  security_groups = [
    "${aws_security_group.allow_http.name}",
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_all_outbound.name}"
  ]

  tags = {
    Name = "${var.name}-ec2"
  }
}
