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

# Add route for the Internet to the routing table.
resource "aws_route" "cloud_internet" {
  route_table_id         = aws_vpc.cloud.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloud_internet.id
}

# Add route entries for cloud1 subnet to the routing table.
resource "aws_route_table_association" "cloud1" {
  route_table_id = aws_vpc.cloud.default_route_table_id
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
