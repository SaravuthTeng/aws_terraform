output "vpc_id" {
  value       = aws_vpc.uat_vpc.id
  description = "The unique ID string generated for the UAT VPC network."
}

output "vpc_arn" {
  value       = aws_vpc.uat_vpc.arn
  description = "The Amazon Resource Name (ARN) identifying your UAT VPC."
}

