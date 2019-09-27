terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "jerome-playground-2019"
    workspaces {
      name = "terraform-aws-hashicat"
    }
  }
}
