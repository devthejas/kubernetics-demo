terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Random suffix for unique bucket name
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# S3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "jenkins-terraform-demo-${random_integer.suffix.result}"
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create a subnet inside the default VPC
resource "aws_subnet" "public_subnet" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.0.0/20"   # valid range inside default VPC
  availability_zone = "ap-south-1a"
}

# Launch EC2 instance in the subnet
resource "aws_instance" "ec2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "jenkins-terraform-demo"
  }
}
