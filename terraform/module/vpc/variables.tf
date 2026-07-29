variable "vpc_cidr_block"{
    description = "Cidr block for VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "tags"{
    description = "Tags to apply to vpc"
    type = map(string)
    default = {}
}


