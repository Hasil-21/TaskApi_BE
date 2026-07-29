resource "aws_internet_gateway" "igw"{
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.name_prefix}-igw"
    }
}

resource "aws_eip" "nat_eip"{
    count = var.create_nat ? 1 : 0
    domain = "vpc"

    tags = {
        Name = "${var.name_prefix}-nat-eip"
    } 
}

resource "aws_nat_gateway" "nat"{
    count = var.create_nat ? 1 : 0
    allocation_id = aws_eip.nat_eip[0].id
    subnet_id = var.public_subnet_ids["a"]

    tags = {
        Name = "${var.name_prefix}-nat"
    }

    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public"{
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.name_prefix}-public-rt"
    }
}

resource "aws_route_table_association" "public"{
    for_each = var.public_subnet_ids
    route_table_id = aws_route_table.public.id
    subnet_id = each.value
}

resource "aws_route_table" "private"{
    vpc_id = var.vpc_id

    dynamic "route" {
        for_each = var.create_nat ? [1] : []
        content {
            cidr_block     = "0.0.0.0/0"
            nat_gateway_id = aws_nat_gateway.nat[0].id
        }
    }

    tags = {
        Name = "${var.name_prefix}-private-rt"
    }
}

resource "aws_route_table_association" "private"{
    for_each = var.private_subnet_ids
    subnet_id = each.value
    route_table_id = aws_route_table.private.id
}