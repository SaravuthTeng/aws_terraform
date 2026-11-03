# Testing code
# delete vpc
resource "aws_vpc" "uat_vpc" {
	cidr_block = "10.10.0.0/16"
	tags = {
		Name = "uat_vpc"
	} 
}
resource "aws_subnet" "private_subnet_app" {
	vpc_id = aws_vpc.uat_vpc.id
	cidr_block = "10.10.1.0/24"
	tags = {
		Name = "private-subnet-app"	
	}
}
