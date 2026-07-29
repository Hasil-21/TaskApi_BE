variable "name_prefix" {
  type    = string
  default = "taskapi"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = map(string)
}

variable "allowed_security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "taskapidb"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}