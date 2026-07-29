variable "vpc_id"{
    type = string
}

variable "public_subnet_ids"{
    type = map(string) 
}

variable "private_subnet_ids"{
    type = map(string)
}

variable "create_nat"{
    type = bool
    default = true
}

variable "name_prefix"{
    type = string
    default = "taskapi"
}