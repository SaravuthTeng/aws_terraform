# A core network boundary for your UAT applications
resource "aws_vpc" "uat_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "uat-core-vpc"
    }
  }
resource "aws_subnet" "public_subnet_uat" {
  cidr_block  = "20.20.1.0/24"
  vpc_id      = aws_vpc.uat_vpc.id
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public-Subnet"
  }
}
resource "aws_subnet" "privat_subnet_uat" {
  cidr_block  = "20.20.2.0/24"
  vpc_id      = aws_vpc.uat_vpc.id

  tags = {
    Name = "Privat-subnet"
  }
}

