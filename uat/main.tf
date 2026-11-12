# A core network boundary for your UAT applications
# vpc_cidr from variable
resource "aws_vpc" "uat_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "uat-core-vpc"
    }
}

# Public Subnet for ALB 
resource "aws_subnet" "public_subnet_uat" {
  cidr_block  = "20.20.1.0/24"
  vpc_id      = aws_vpc.uat_vpc.id
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public-Subnet"
  }
}

# Private Subnet for wordpress setup connect to DB
resource "aws_subnet" "privat_subnet_uat" {
  cidr_block  = "20.20.2.0/24"
  vpc_id      = aws_vpc.uat_vpc.id

  tags = {
    Name = "Privat-Subnet"
  }
}

# Isolated subnet for RDS Aura DB 
resource "aws_subnet" "isolated_subnet_uat" {
  cidr_block  = "20.20.3.0/24"
  vpc_id      = aws_vpc.uat_vpc.id

  tags = {
    Name = "Isolated_Subnet"
  }
}

# Security group for public private and isolated subnet

### Load Balance Web sg
resource "aws_security_group" "public_sg" {
  name    = "First-tier-sg"
  vpc_id  = aws_vpc.uat_vpc.id
  description = "Allow HTTP/HTTPS traffic from internet"
}
resource "aws_vpc_security_group_ingress_rule" "public_https" {
  security_group_id   = aws_security_group.public_sg.id
  cidr_ipv4  = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "public_to_privat" {
  security_group_id   = aws_security_group.public_sg.id
  referenced_security_group_id   = aws_security_group.private_sg.id
  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}

### Wordpress from LB / to DB

resource "aws_security_group" "private_sg" {
  name    = "Second-tier-sg"
  vpc_id  = aws_vpc.uat_vpc.id
  description = "Allow from only public_sg"
}
resource "aws_vpc_security_group_ingress_rule" "private_from_public" {
  security_group_id   = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id
  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "privat_to_natgw" {
  security_group_id   = aws_security_group.private_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

}


### Aura DB from wordpress only

resource "aws_security_group" "isolate_sg" {
  name    = "Three-tier-sg"
  vpc_id  = aws_vpc.uat_vpc.id
  description = "Allow from only private_sg"
}
resource "aws_vpc_security_group_ingress_rule" "isolat_from_privat" {
  security_group_id   = aws_security_group.isolate_sg.id
  referenced_security_group_id = aws_security_group.private_sg.id
  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}

 


