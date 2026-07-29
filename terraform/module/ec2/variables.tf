variable "name_prefix" {
  type    = string
  default = "taskapi"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  description = "Subnet where the EC2 instance will run"
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID for ap-south-1"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "key_name" {
  type        = string
}

variable "my_ip" {
  type        = string
}