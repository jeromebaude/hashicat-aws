##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "jerome"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "eu-north-1"
}

variable "ami" {
  description = "The AMI id being used"
  default     = "ami-0f99dca6fd2ed7c0a"
}

variable "enable_dns_hostnames" {
  description = "enable dns hostnames"
  default     = "false"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.nano"
}

variable "admin_username" {
  description = "Administrator user name for mysql"
  default     = "hashicorp"
}

variable "height" {
  default     = "400"
  description = "Image height in pixels."
}

variable "width" {
  default     = "600"
  description = "Image width in pixels."
}

variable "placeholder" {
  default     = "placekitten.com"
  description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
}

variable "create" {
  description = "Create Module, defaults to true."
  default     = true
}

variable "permissions" {
  description = "The Unix file permission to assign to the cert files (e.g. 0600). Defaults to \"0600\"."
  default     = "0600"
}
