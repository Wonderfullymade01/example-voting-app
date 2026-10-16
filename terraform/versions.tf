# Which Terraform version and which plugins (providers) this project needs
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Connect to AWS in our region, using the credentials from `aws configure`
provider "aws" {
  region = var.region

  # Tag everything Terraform creates, so it's easy to find in the console and on the bill
  default_tags {
    tags = {
      Project   = "capstone-voting-app"
      ManagedBy = "terraform"
    }
  }
}
