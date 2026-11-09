# A core network boundary for your UAT applications
resource "aws_vpc" "uat_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "uat-core-vpc"
  }
}

