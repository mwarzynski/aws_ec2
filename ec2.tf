# Resource of my RSA public key.
# Allows to gain access over SSH to the EC2 instance.
resource "aws_key_pair" "ssh" {
  key_name   = "${var.name}-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# We need the AWS AMI (Amazon Machine ID) to set up our EC2 instance.
# Images become different as they are being upgraded. We would like to use the latest version.
# For this purpose I defined data source being `aws_ami` which provides ID of the image.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Commands to run after EC2 instance was initialized.
# We would like to run simple HTTP server to test if Load Balancer serves HTTP requests properly (rotating the instances).
# I launch apache2 as a HTTP server which serve on port 80 by default.
# Feel free to change the index.html contents to something more funny.
locals {
  ec2_init_commands = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    echo "Terraform" | sudo tee /var/www/html/index.html
    EOT
}

# EC2 instance launch template.
# It's required for Auto Scaling group, as it needs to know how to initialize new instances.
resource "aws_launch_template" "instance_template" {
  name          = "${var.name}-ec2-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.cloud.id,
    aws_security_group.cloud1.id
  ]
  key_name  = aws_key_pair.ssh.key_name
  user_data = base64encode(local.ec2_init_commands)
}

# Auto Scaling group defines instances group.
# To define policies regarding scaling instances use 'aws_autoscaling_policy'.
resource "aws_autoscaling_group" "cloud" {
  name             = "${var.name}-ec2-ag"
  max_size         = 3
  min_size         = 1
  desired_capacity = 2

  load_balancers      = [aws_elb.cloud.id]
  vpc_zone_identifier = [aws_subnet.cloud1.id]

  launch_template {
    id      = aws_launch_template.instance_template.id
    version = "$Latest"
  }
}
