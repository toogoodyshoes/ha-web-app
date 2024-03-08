provider "aws" {
  region = "ap-south-1"
}

module "network" {
  source = "./modules/network"
}

module "data" {
  source = "./modules/data"
}

module "application" {
  source = "./modules/application"
}
