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
  folder_id = local.folder_hr_link_tf_id
  zone      = local.zone
  #   cloud_id  = var.cloud_id
}

data "local_file" "main_config" {
  filename = var.main_config
}

locals {
  parsed_main_config          = jsondecode(data.local_file.main_config.content)
  zone                        = local.parsed_main_config["zone"]
  filesystem_name_mask        = local.parsed_main_config["filesystem-name-mask"]
  filesystem_device_name_mask = local.parsed_main_config["filesystem-device-name-mask"]
  folder_hr_link_tf_id        = local.parsed_main_config["folders"]["folder-hr-link-tf"]["id"]

  network_name_mask    = local.parsed_main_config["network-name-mask"]
  subnetwork_name_mask = local.parsed_main_config["subnetwork-name-mask"]
}

module "network" {
  source              = "../../../modules/yandex/vpc-network"
  network_name        = local.network_name_mask
  network_description = "Сеть"
}

module "subnetwork-private" {
  source = "../../../modules/yandex/vpc-subnetwork"

  network_id             = module.network.id
  subnetwork_name        = "${local.subnetwork_name_mask}-private"
  subnetwork_description = "Приватная подсеть"
  cidr_v4                = var.subnetwork_cidr_v4_private
}

module "subnetwork-public" {
  source = "../../../modules/yandex/vpc-subnetwork"

  network_id             = module.network.id
  subnetwork_name        = "${local.subnetwork_name_mask}-public"
  subnetwork_description = "Публичная подсеть"
  cidr_v4                = var.subnetwork_cidr_v4_public
}
