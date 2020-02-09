variable "name" {
  default     = "worker-instance"
  type        = string
  description = "Prefix for managed resources names."
}

variable "instance_type" {
  default     = "t2.nano"
  type        = string
  description = "Type of the EC2 instance to create. (https://aws.amazon.com/ec2/instance-types/)"
}

variable "myip" {
  type        = string
  description = "IPv4 address of the host which should be allowed to SSH into the EC2 instance."
}
