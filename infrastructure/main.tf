terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }
  }
  backend "s3" {
    bucket = "boxer-s3-bucket"
    key = "work/boxer/infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  prefix = terraform.workspace == "production" ? "boxer" : "boxer-${terraform.workspace}"
  default_tags = {
    Name        = local.prefix
    Provisioner = "https://gitlab.com/3pg-devops-internship/boxer"
    Owner       = "vivien.bartis@3pillarglobal.com"
  }
}