terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "backend" {
  source                                              = "./modules/remote_backend"
  iam_user_name                                       = var.iam_user_name
  bucket_name                                         = var.bucket_name
  table_name                                          = var.table_name
}

output "iam_user_name" {
  value                                               = module.backend.iam_user_arn
}

module "dns_acm" {
  source = "./modules/route53_acm"
  root_domain = var.root_domain
  dns_record_ttl = var.dns_record_ttl
}