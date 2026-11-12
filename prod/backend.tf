 terraform {
   backend "s3" {
     bucket         = "teng-devops-tfstate-bucket-log"
     key            = "environments/prod/terraform.tfstate"
     region         = "ap-southeast-2"
     use_lockfile   = true #  Native S3 locking
     encrypt        = true
   }
 }

