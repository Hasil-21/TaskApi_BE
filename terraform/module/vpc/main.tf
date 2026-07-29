resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr_block
    tags = var.tags
    enable_dns_hostnames = true
    enable_dns_support = true
}