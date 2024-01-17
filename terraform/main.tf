terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "backend" {
  source                                              = "./modules/remote_backend"
  iam_user_name                                       = var.iam_user_name
  bucket_name                                         = var.bucket_name
  table_name                                          = var.table_name
}

module "dns_acm" {
  source                                              = "./modules/route53_acm"
  root_domain                                         = var.root_domain
  dns_record_ttl                                      = var.dns_record_ttl
}

module "s3_website" {
  source                                              = "./modules/s3_website"
  website_bucket                                      = var.website_bucket
  force_destroy                                       = var.force_destroy
  versioning_enabled                                  = var.versioning_enabled
  index_document                                      = var.index_document
  region                                              = var.region
}

module "cloudfront" {
  source                                              = "./modules/s3_cloudfront"
  bucket_regional_domain_name                         = module.s3_website.bucket_regional_domain_name
  s3_bucket_id                                        = module.s3_website.s3_bucket_id
  route53_zone_id                                     = module.dns_acm.route53_zone_id
  ssl_cert_arn                                        = module.dns_acm.ssl_cert_arn
  index_document                                      = module.s3_website.index_document
  root_domain                                         = module.dns_acm.root_domain
}