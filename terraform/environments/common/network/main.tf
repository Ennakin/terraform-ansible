terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
  }

  backend "http" {}
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

module "network" {
  source       = "../../../modules/vpc-network"
  network_name = var.network_name
}

module "subnetwork-private" {
  source = "../../../modules/vpc-subnetwork"

  network_id      = module.network.id
  subnetwork_name = "${var.subnetwork_name}-private"
  cidr_v4         = var.subnetwork_cidr_v4_private
}

module "subnetwork-public" {
  source = "../../../modules/vpc-subnetwork"

  network_id      = module.network.id
  subnetwork_name = "${var.subnetwork_name}-public"
  cidr_v4         = var.subnetwork_cidr_v4_public
}
