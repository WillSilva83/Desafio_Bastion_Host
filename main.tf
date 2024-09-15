provider "aws" {
  region = var.vpc_main

}


module "instance_main" {
  source = "./services/instance"
}