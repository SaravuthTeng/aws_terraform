### Three Tier Network information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc_three_tier.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs for WordPress App"
  value       = aws_subnet.private_subnet[*].id
}

output "isolated_subnet_ids" {
  description = "List of isolated subnet IDs for Aurora/RDS"
  value       = aws_subnet.isolated_subnet[*].id
}

output "public_sg_id" {
  description = "Security Group ID for Public ALB"
  value       = aws_security_group.public_sg.id
}

output "private_sg_id" {
  description = "Security Group ID for Private WordPress App"
  value       = aws_security_group.private_sg.id
}

output "isolate_sg_id" {
  description = "Security Group ID for Isolated Database"
  value       = aws_security_group.isolate_sg.id
}

