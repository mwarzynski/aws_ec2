output "lb_host" {
  value = aws_elb.cloud.dns_name
}
