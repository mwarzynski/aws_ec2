output "ec2_instance_public_ip" {
  value = aws_spot_instance_request.instance_request.public_ip
}
