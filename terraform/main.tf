module "taskapi_vpc" {
    source = "./module/vpc"

    vpc_cidr_block = "10.0.0.0/16"

    tags = {
        Project = "TaskApi"
    }
}


module "taskapi_public_subnet_1"{
    source = "./module/subnet"

    vpc_id = module.taskapi_vpc.vpc_id
    subnet_cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "taskapi_public_subnet_1"
    }
}

module "taskapi_public_subnet_2"{
    source = "./module/subnet"

    vpc_id = module.taskapi_vpc.vpc_id
    subnet_cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"

    tags = {
        Name = "taskapi_public_subnet_2"
    }
}

module "taskapi_private_subnet_1"{
    source = "./module/subnet"

    vpc_id = module.taskapi_vpc.vpc_id
    subnet_cidr_block = "10.0.3.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "taskapi_private_subnet_1"
    }
}

module "taskapi_private_subnet_2"{
    source = "./module/subnet"

    vpc_id = module.taskapi_vpc.vpc_id
    subnet_cidr_block = "10.0.4.0/24"
    availability_zone = "ap-south-1b"

    tags = {
        Name = "taskapi_private_subnet_2"
    }
}


module "taskapi_routing" {
  source = "./module/routing"

  vpc_id = module.taskapi_vpc.vpc_id
  public_subnet_ids = {
    a = module.taskapi_public_subnet_1.subnet_id
    b = module.taskapi_public_subnet_2.subnet_id
  }

  private_subnet_ids = {
    a = module.taskapi_private_subnet_1.subnet_id
    b = module.taskapi_private_subnet_2.subnet_id
  }
  
  create_nat = true   
  name_prefix = "taskapi"
}

module "ec2-app"{
    source = "./module/ec2"

    vpc_id = module.taskapi_vpc.vpc_id
    public_subnet_id = module.taskapi_public_subnet_1.subnet_id
    ami_id = "ami-006f82a1d5a27da54"
    key_name = "DemoKeyPair"
    my_ip = "202.131.123.10/32"
}

module "rds"{
    source = "./module/rds"

    vpc_id = module.taskapi_vpc.vpc_id
    private_subnet_ids = {
        a = module.taskapi_private_subnet_1.subnet_id
        b = module.taskapi_private_subnet_2.subnet_id
    }
    allowed_security_group_id = module.ec2-app.ec2_sg_id
    
    db_username = "taskapiadmin"
    db_password = "SuperSecretDBPass1234"
}


resource "aws_security_group" "jenkins-sg"{
    name = "jenkins-sg"
    description = "jenkins controller security group"
    vpc_id = module.taskapi_vpc.vpc_id

    ingress {
      description = "allow to access jenkins controller UI"
      to_port = 8080
      from_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
       description = "allow to ssh into the controller"
       to_port = 22
       from_port = 22
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
      Name = "jenkins-sg"
    }
}

resource "aws_instance" "ec2-jenkins-controller" {
    ami = "ami-006f82a1d5a27da54"
    instance_type = "t3.small"
    subnet_id = module.taskapi_public_subnet_1.subnet_id
    vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
    key_name = "DemoKeyPair"
    associate_public_ip_address = true

    tags = {
	Name = "Jenkins-Controller"
    }
}
