# Testing code
resource "aws_vpc" "uat_vpc" {
  cidr = "10.10.0.0/16"
  tags = {
    Name = "uat-vpc"
  }
}
