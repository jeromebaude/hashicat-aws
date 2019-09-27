terraform {
  required_version = ">= 0.12.1"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

module "networking" {
  source                                      = "jnonino/networking/aws"
  version                                     = "2.0.3"
  name_preffix                                = "base"
  profile                                     = "aws_profile"
  region                                      = "us-west-2"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19", "192.168.96.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19", "192.168.224.0/19"]
}

module "ecs-fargate" {
  source                       = "app.terraform.io/YOURORGNAME/ecs-fargate/aws"
  version                      = "2.0.4"
  name_preffix                 = "${var.prefix}"
  profile                      = "aws_profile"
  region                       = "us-west-2"
  vpc_id                       = "${module.networking.vpc_id}"
  availability_zones           = "${module.networking.availability_zones}"
  public_subnets_ids           = "${module.networking.public_subnets_ids}"
  private_subnets_ids          = "${module.networking.private_subnets_ids}"
  container_name               = "${var.prefix}"
  container_image              = "scarolan/palacearcade:latest"
  essential                    = true
  container_port               = 80
  environment                  = []
}
output "lb_dns_name" {
    value = "${module.ecs-fargate.lb_dns_name}"
}
