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

locals {
  parsed_servers_hrl   = jsondecode(var.servers_hrl)
  parsed_servers_strl  = jsondecode(var.servers_strl)
  parsed_servers_space = jsondecode(var.servers_space)
}

module "disk-hrl" {
  source = "../../../modules/disk"

  for_each = local.parsed_servers_hrl

  secondary_disk_name        = "hrl-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "HRL-DISK-onprem-${each.value}"
  secondary_disk_size        = 30
}

module "disk-strl" {
  source = "../../../modules/disk"

  for_each = local.parsed_servers_strl

  secondary_disk_name        = "strl-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "STRL-DISK-onprem-${each.value}"
  secondary_disk_size        = 30
}
