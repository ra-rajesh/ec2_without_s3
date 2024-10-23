# Provider
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }
# S3-terraform.tfstate

#   backend "s3" {
#     bucket = "git-terra-aws"
#     key    = "terraform.tfstate"
#     region = "us-east-1"
#   }
#  } this inside the terraform 

# Configure the AWS Provider
provider "aws" {
  region = var.region_name
}
# VPC
resource "aws_vpc" "vpc_terraform" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags = {
    Name = "var.vpc_tag_name" # "vpc_terraform"
  }
}
# VPC-Subnet
resource "aws_subnet" "pub_sub_terraform" {
  vpc_id            = aws_vpc.vpc_terraform.id
  cidr_block        = var.vpc_sn_cidr_block    # "10.0.1.0/24"
  availability_zone = var.sn_availability_zone # "us-east-1a"

  tags = {
    Name = "var.pub_sn_tags" # "pub_sub_terraform"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "igw_terraform" {
  vpc_id = aws_vpc.vpc_terraform.id

  tags = {
    Name = "var.igw_tags" # "igw_terraform"
  }
}
# Route Table
resource "aws_route_table" "rt_terraform" {
  vpc_id = aws_vpc.vpc_terraform.id
  route {
    cidr_block = var.rt_cidr_block # "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_terraform.id
  }
  tags = {
    Name = "var.rt_tags" # "rt_terraform"
  }
}
# Route table Association
resource "aws_route_table_association" "rta_terraform" {
  subnet_id      = aws_subnet.pub_sub_terraform.id
  route_table_id = aws_route_table.rt_terraform.id
}
# Security Group
resource "aws_security_group" "sg_terraform" {
  name        = "var.sg_name" # "sg_allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc_terraform.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "var.sg_tags" # "sg_terraform"
  }
}
# Instance details
resource "aws_instance" "ec2-terraform" {
  ami                         = "ami-005fc0f236362e99f"
  availability_zone           = var.ec2_az            # "us-east-1a"
  instance_type               = var.ec2_instance_type # "t2.micro"
  key_name                    = var.ec2_key_name      # "nvirginia-017"
  subnet_id                   = aws_subnet.pub_sub_terraform.id
  vpc_security_group_ids      = ["${aws_security_group.sg_terraform.id}"]
  associate_public_ip_address = true
  tags = {
    Name  = "terraform-1"
    Env   = "add-new"
    Owner = "Rajesh"
  }
}
