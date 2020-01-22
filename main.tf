terraform {
  required_version = ">= 0.12.1"
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

module "hashicat-module" {
  source      = "app.terraform.io/jerome-playground/hashicat-module/aws"
  version     = "1.1.4"
  prefix      = var.prefix
  height      = var.height
  width       = var.width
  placeholder = var.placeholder
}
