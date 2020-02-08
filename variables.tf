variable "name" {
  default = "worker-instance"
  type    = string
}

variable "instance_type" {
  default = "t2.nano"
  type    = string
}

variable "myip" {
  type    = string
}
