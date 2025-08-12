terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-expense"
    key            = "expense-dev-SSL/TLS" # keys are always unque within the bucket
    region         = "us-east-1"
    dynamodb_table = "terraform-locking"
  }

}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}