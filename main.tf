
### Terraform configuration
terraform {
  required_version = ">=1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


### Provider
provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}