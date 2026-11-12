variable "aws_region" {
  type        = string
  default     = "ap-southeast-2"
  description = "The primary AWS target region for the UAT workload."
}

variable "vpc_cidr" {
  type        = string
  default     = "20.20.0.0/16"
  description = "The core CIDR block block allocated to the UAT network environment."
}
variable "environment" {
  type        = string
  default     = "dev" 
}
