provider "aws" {
  region = "ap-south-1"
}

module "network" {
  source = "./modules/network"
}

module "data" {
  source = "./modules/data"

  vpc-id = module.network.wp_vpc.id
  zone-a-subnets = module.network.zone_a_subnets
  zone-b-subnets = module.network.zone_b_subnets
}

module "application" {
  source = "./modules/application"

  vpc-id = module.network.wp_vpc.id
  zone-a-subnets = module.network.zone_a_subnets
  zone-b-subnets = module.network.zone_b_subnets
  db-client-sg-id = module.data.db_client_sg.id
  wp-fs-client-sg-id = module.data.wp_fs_client_sg.id
}
