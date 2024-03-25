
provider "aws" {
  region = var.region_primary //"us-east-1"
  alias  = "primary"
  # fake config for terraform plan check without aws access
  # must be deleted or overwritten in real environment
  # start fake config
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "fake_mock_access_key"
  secret_key                  = "fake_mock_secret_key"
  # enf fake config
  default_tags {
    tags = merge(local.default_tags, { "identifier" = "PRIMARY" })
  }
}

provider "aws" {
  region                      = var.region_secondary
  alias                       = "secondary"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "fake_mock_access_key"
  secret_key                  = "fake_mock_secret_key"
  default_tags {
    tags = merge(local.default_tags, { "identifier" = "DISASTER RECOVERY" })
  }
}

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.15.0"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
}
