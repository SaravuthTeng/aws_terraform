terraform {
  required_version = ">= 1.17.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}

# Configured to build your backend in Sydney
provider "aws" {
  region = "ap-southeast-2" 
}

# The S3 Bucket matching your exact backend configuration
resource "aws_s3_bucket" "tf_state" {
  bucket        = "teng-devops-tfstate-bucket-log"
  force_destroy = false 
}

# Turn on versioning for state backups
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state files at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_crypto" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to state bucket
resource "aws_s3_bucket_public_access_block" "tf_state_public_access" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

}
