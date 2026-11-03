terraform {
  required_version = ">= 1.10.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This backend block is critical! Without it, deletion will fail on GitHub Actions.
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket" 
    key            = "environments/dev/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = "ap-southeast-2"
}
