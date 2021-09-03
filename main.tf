terraform {
  backend "s3" {
    bucket         = "test-tfstate-abg"
    dynamodb_table = "tfstate-lock-test"
    encrypt        = true
    key            = "st/static-website"
    region         = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.56"
    }
  }
}

provider "aws" {
  region = var.region

}
