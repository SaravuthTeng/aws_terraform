terraform {
  # Targets the latest Terraform 1.17 Release Line
  required_version = ">= 1.17.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Automatically tracks the latest v6.x major update releases
      version = "~> 6.0"
    }
  }

  # Connects the remote runner to your shared S3 tracking bucket
  backend "s3" {
    bucket         = "teng-aws-gitops-tfstat" 
    key            = "global/gitops/terraform.tfstate"         
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock-table"               
    encrypt        = true                                  
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

