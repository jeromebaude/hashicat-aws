terraform {
  required_version = ">= 0.12.1"
}

provider "aws" {
  version = "~> 2.0"
  region  = "${var.region}"
}

module "networking" {
  source                                      = "jnonino/networking/aws"
  version                                     = "2.0.3"
  name_preffix                                = "base"
  profile                                     = "aws_profile"
  region                                      = "eu-north-1"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19", "192.168.96.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19", "192.168.224.0/19"]
}

module "ecs-fargate" {
  source                       = "app.terraform.io/jerome-playground-2019/ecs-fargate/aws"
  version                      = "2.0.4"
  name_preffix                 = "${var.prefix}"
  profile                      = "aws_profile"
  region                       = "${var.region}"
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

#resource "tls_private_key" "hashicat" {
#  algorithm = "RSA"
#}
#
#locals {
#  private_key_filename = "${var.prefix}-ssh-key.pem"
#}
#
#resource "aws_key_pair" "hashicat" {
#  key_name   = "${local.private_key_filename}"
#  public_key = "${tls_private_key.hashicat.public_key_openssh}"
#}
#
#resource "aws_vpc" "hashicat" {
#  cidr_block           = "${var.address_space}"
#  enable_dns_hostnames = false
#
#  tags = {
#    Name = "${var.prefix}-vpc"
#  }
#}
#
#resource "aws_subnet" "hashicat" {
#  vpc_id     = "${aws_vpc.hashicat.id}"
#  cidr_block = "${var.subnet_prefix}"
#
#  tags = {
#    name = "${var.prefix}-subnet"
#  }
#}
#
#resource "aws_security_group" "hashicat" {
#  name = "${var.prefix}-security-group"
#
#  vpc_id = "${aws_vpc.hashicat.id}"
#
#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port       = 0
#    to_port         = 0
#    protocol        = "-1"
#    cidr_blocks     = ["0.0.0.0/0"]
#    prefix_list_ids = []
#  }
#
#  tags = {
#    Name = "${var.prefix}-security-group"
#  }
#}
#
#resource "aws_eip" "hashicat" {
#  instance = "${aws_instance.hashicat.id}"
#  vpc      = true
#
#  tags = {
#    Name = "${var.prefix}-elastic-ip"
#  }
#}
#
#resource "aws_internet_gateway" "hashicat" {
#  vpc_id = "${aws_vpc.hashicat.id}"
#
#  tags = {
#    Name = "${var.prefix}-internet-gateway"
#  }
#}
#
#resource "aws_route_table" "hashicat" {
#  vpc_id = "${aws_vpc.hashicat.id}"
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = "${aws_internet_gateway.hashicat.id}"
#  }
#}
#
#resource "aws_route_table_association" "hashicat" {
#  subnet_id      = "${aws_subnet.hashicat.id}"
#  route_table_id = "${aws_route_table.hashicat.id}"
#}
#
#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
#    # values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["099720109477"] # Canonical
#}
#
#resource "aws_instance" "hashicat" {
#  ami                         = "${data.aws_ami.ubuntu.id}"
#  instance_type               = "${var.instance_type}"
#  key_name                    = "${aws_key_pair.hashicat.key_name}"
#  associate_public_ip_address = true
#  subnet_id                   = "${aws_subnet.hashicat.id}"
#  vpc_security_group_ids      = ["${aws_security_group.hashicat.id}"]
#
#  tags = {
#    Name = "${var.prefix}-hashicat-instance"
#  }
#}
#
## We're using a little trick here so we can run the provisioner without
## destroying the VM. Do not do this in production.
#
## If you need ongoing management (Day N) of your virtual machines a tool such
## as Chef or Puppet is a better choice. These tools track the state of
## individual files and can keep them in the correct configuration.
#
## Here we do the following steps:
## Sync everything in files/ to the remote VM.
## Set up some environment variables for our script.
## Add execute permissions to our scripts.
## Run the deploy_app.sh script.
#resource "null_resource" "configure-cat-app" {
#  depends_on = [
#    "aws_instance.hashicat",
#  ]
#
#  # Terraform 0.11
#  # triggers {
#  #   build_number = "${timestamp()}"
#  # }
#
#  # Terraform 0.12
#  triggers = {
#    build_number = "${timestamp()}"
#  }
#  provisioner "file" {
#    source      = "files/"
#    destination = "/home/ubuntu/"
#
#    connection {
#      type        = "ssh"
#      user        = "ubuntu"
#      private_key = "${tls_private_key.hashicat.private_key_pem}"
#      host        = "${aws_eip.hashicat.public_ip}"
#    }
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt -y install apache2",
#      "sudo systemctl start apache2",
#      "sudo chown -R ubuntu:ubuntu /var/www/html",
#      "chmod +x *.sh",
#      "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
#    ]
#
#    connection {
#      type        = "ssh"
#      user        = "ubuntu"
#      private_key = "${tls_private_key.hashicat.private_key_pem}"
#      host        = "${aws_eip.hashicat.public_ip}"
#    }
#  }
#}
