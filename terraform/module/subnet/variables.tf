variable "subnet_cidr_block"{
    description = "Cidr block of subnet"
    type = string
}

variable "vpc_id"{
    description = "vpc in which subnet is present"
    type = string
}

variable "tags"{
    description = "tags of subnet"
    type = map(string)
}

variable "availability_zone"{
    type = string
}
