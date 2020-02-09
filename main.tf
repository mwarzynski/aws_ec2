provider "aws" {}

# Define 'Virtual Private Cloud' for the instance.
# It allows to completely separate network only for this project.
# (For the same reason, we don't want to use default VPC.)
resource "aws_vpc" "cloud" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${var.name}-cloud"
  }
}

# Define 'Internet Gateway' as a gateway for the external network (Internet).
resource "aws_internet_gateway" "cloud_internet" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    Name = "${var.name}-cloud-internet"
  }
}

# Create subnet network for the EC2 instance(s).
# Let's name it with the '1' suffix as the subnet has 16-24 bits equal to 1.
resource "aws_subnet" "cloud1" {
  vpc_id     = aws_vpc.cloud.id
  cidr_block = cidrsubnet(aws_vpc.cloud.cidr_block, 8, 1)
  # Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-cloud1"
  }
}

# Define routing table for the network.
resource "aws_route_table" "cloud" {
  vpc_id = aws_vpc.cloud.id

  # Route the traffic to the Internet Gateway if the host is not known (local).
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud_internet.id
  }
}

# Add route entries for cloud1 subnet to the routing table.
resource "aws_route_table_association" "cloud1" {
  route_table_id = aws_route_table.cloud.id
  subnet_id      = aws_subnet.cloud1.id
}

# Define security group for the VPC.
# It allows to specify what traffic is allowed.
resource "aws_security_group" "cloud" {
  name   = "${var.name}-cloud"
  vpc_id = aws_vpc.cloud.id

  # Allow inbound SSH traffic from my host.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myip}/32"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

# Define the EC2 Spot Instance Request.
# Use AMI (Amazon Machine ID) from the datasource defined above.
resource "aws_spot_instance_request" "instance_request" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  spot_type       = "one-time"
  key_name        = aws_key_pair.ssh.key_name
  security_groups = [aws_security_group.cloud.id]
  subnet_id       = aws_subnet.cloud1.id
  # We need to wait until Instance will be properly fulfilled.
  # Otherwise, we won't be able to fetch `public_ip` which is required as output value.
  wait_for_fulfillment = true

  tags = {
    Name = "${var.name}-ec2-request"
  }
}
