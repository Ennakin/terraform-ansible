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

data "local_file" "servers_and_disks" {
  filename = var.servers_and_disks
}

data "local_file" "environments_config" {
  filename = var.environments_config
}

locals {
  parsed_servers_and_disks = jsondecode(data.local_file.servers_and_disks.content)
  servers_hrl              = local.parsed_servers_and_disks["hrl"]["dev"]
  servers_strl             = local.parsed_servers_and_disks["strl"]["dev"]

  parsed_environment_config = jsondecode(data.local_file.environments_config.content)
  disk_name_mask            = local.parsed_environment_config["dev"]["disk-name-mask"]
}

module "disk-hrl" {
  source = "../../../modules/yandex/disk"

  for_each = local.servers_hrl

  secondary_disk_name        = "hrl-${local.disk_name_mask}-${each.key}"
  secondary_disk_description = "HRL-DISK-dev-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}

module "disk-strl" {
  source = "../../../modules/yandex/disk"

  for_each = local.servers_strl

  secondary_disk_name        = "strl-${local.disk_name_mask}-${each.key}"
  secondary_disk_description = "STRL-DISK-dev-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}
