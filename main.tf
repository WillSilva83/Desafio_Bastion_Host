provider "aws" {
  region = var.vpc_main

}


module "network_main" {
  source = "./services/network"
}


module "instance_main" {
  source = "./services/instance"
}