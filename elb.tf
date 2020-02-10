# (Classic) Load Balancer to serve traffic using multiple EC2 instances.
resource "aws_elb" "cloud" {
  name = "${var.name}-lb"
  # Load Balancer needs permissions only for the cloud1 subnet, because only there are EC2 instances.
  subnets         = [aws_subnet.cloud1.id]
  security_groups = [aws_security_group.cloud1.id]

  listener {
    # Our EC2 instances provide only the HTTP (without SSL) traffic.
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    # For learning purpose, values below are fine.
    # However, for production environment, you should pick something that provide more reliability.
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    target              = "HTTP:80/"
    interval            = 5
  }

  idle_timeout        = 400
  connection_draining = false
}
