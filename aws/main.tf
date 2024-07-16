terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  alias  = "test"
  region = "ap-south-1"
}

#Create EC2 Instance
resource "aws_instance" "devsecops_demo" {
  ami           = "ami-0ec0e125bb6c6e8ec"
  instance_type = "t2.micro"

  tags = {
    Name = "DevsecopsDemo"
  }
}