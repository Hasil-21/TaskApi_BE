resource "aws_security_group" "ec2_sg"{
    name = "${var.name_prefix}-ec2-sg"
    vpc_id = var.vpc_id
    description = "Security group for app ec2 instance"

    ingress{
        description = "SSH allowed from my IP"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Taskapi app port"
        to_port = 5000
        from_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    tags = {
        Name = "${var.name_prefix}-ec2-sg"
    }
}

resource "aws_instance" "this"{
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.public_subnet_id
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true

    tags = {
        Name = "${var.name_prefix}-ec2"
    }
}
