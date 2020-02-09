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
