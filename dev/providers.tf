# providers.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "devops"
      ManagedBy   = "Terraform"
      Owner       = "teng saravuth"
    }
  }
}

