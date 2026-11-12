## Declare var
variable "environment" {
  description = "Environment name (e.g., uat, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The core CIDR block allocated to the VPC (e.g., 10.10.0.0/16)"
  type        = string
}

variable "azs" {
  description = "List of two Availability Zones"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "single_nat_gateway" {
  description = "Use 1 NAT Gateway for cost savings (true for UAT) or 2 for High Availability (false for Prod)"
  type        = bool
  default     = true
}

variable "app_port" {
  description = "Port the WordPress application listens on (e.g., 80 or 8080)"
  type        = number
  default     = 80
}

