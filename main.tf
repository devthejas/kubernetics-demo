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

# Create a new VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create a subnet inside the new VPC
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.1.0/24"
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
