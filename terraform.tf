terraform {
  cloud {
    organization = "nile_org"
    workspaces {
      name = "main-workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }
}