
provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  backend "s3" {
    # see detailed bucket configuration in configs/backend/<ENV>.sh file
  }

  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.00"
    }
  }
}


