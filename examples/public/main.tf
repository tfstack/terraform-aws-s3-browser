############################################
# Provider Configuration
############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}

module "s3_browser" {
  source = "../.."

  s3_config = {
    bucket_name          = "s3-browser"
    bucket_suffix        = random_string.suffix.result
    enable_force_destroy = true
    source_file_path   = "${path.module}/external"
    allowed_principals = ["*"]
  }

  logging_config = {
    enable               = true
    enable_encryption    = true
    encryption_algorithm = "AES256"
    log_retention_days   = 30
    s3_prefix            = "s3/"
  }

  tags = {
    Name = "s3-browser-${random_string.suffix.result}"
  }
}

output "s3_website_url" {
  value = module.s3_browser.s3_website_url
}
