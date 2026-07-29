terraform{
    required_version = ">= 1.5.0"

    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3"{
	bucket = "hasil-terraform-state-bucket"
	key = "taskapi/terraform.tfstate"
	region = "ap-south-1"
	dynamodb_table = "taskapi-terraform-lock"
	encrypt = true
    }
}

provider "aws"{
    region = "ap-south-1"
}
