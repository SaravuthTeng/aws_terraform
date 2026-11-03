# Testing code
# delete vpc
resource "aws_vpc" "uat_vpc" {
	cidr_block = "10.10.0.0/16"
	tags = {
		Name = "uat_vpc"
	} 
}
