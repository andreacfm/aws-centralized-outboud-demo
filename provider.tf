terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
  alias  = "master"
}

provider "aws" {
  region = var.aws_region
  alias  = "prod"
  assume_role {
    role_arn = var.prod_iam_role_arn
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "dev"
  assume_role {
    role_arn = var.dev_iam_role_arn
  }
}