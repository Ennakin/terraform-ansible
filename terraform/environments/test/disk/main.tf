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
  token     = var.YC_IAM_TOKEN
  folder_id = local.folder_hr_link_tf_id
  zone      = local.zone
  #   cloud_id  = var.cloud_id
}

data "local_file" "main_config" {
  filename = var.main_config
}

data "local_file" "environments_config" {
  filename = var.environments_config
}

data "local_file" "servers_and_disks" {
  filename = var.servers_and_disks
}

locals {
  parsed_main_config   = jsondecode(data.local_file.main_config.content)
  zone                 = local.parsed_main_config["zone"]
  folder_hr_link_tf_id = local.parsed_main_config["folders"]["folder-hr-link-tf"]["id"]

  parsed_environment_config = jsondecode(data.local_file.environments_config.content)
  disk_name_mask            = local.parsed_environment_config["test"]["disk-name-mask"]

  parsed_servers_and_disks = jsondecode(data.local_file.servers_and_disks.content)
  servers_and_disks_hrl    = local.parsed_servers_and_disks["hrl"]["test"]
  servers_and_disks_strl   = local.parsed_servers_and_disks["strl"]["test"]
  servers_and_disks_space  = local.parsed_servers_and_disks["space"]["test"]
}

module "disk-hrl" {
  source = "../../../modules/yandex/disk"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key != "stress-1"
  }

  secondary_disk_name        = "hrl-${local.disk_name_mask}-${each.key}"
  secondary_disk_description = "HRL-DISK-test-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}

module "disk-hrl-large-ssd" {
  source = "../../../modules/yandex/disk"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key == "stress-1"
  }

  secondary_disk_name        = "hrl-${local.disk_name_mask}-${each.key}"
  secondary_disk_description = "HRL-DISK-test-${each.value}"
  secondary_disk_size        = 200
  secondary_disk_type        = "network-ssd"
}

module "disk-strl" {
  source = "../../../modules/yandex/disk"

  for_each = local.servers_and_disks_strl

  secondary_disk_name        = "strl-${local.disk_name_mask}-${each.key}"
  secondary_disk_description = "STRL-DISK-test-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}

module "disk-space-kaspersky-admin" {
  source = "../../../modules/yandex/disk"

  for_each = {
    for key, value in local.servers_and_disks_space : key => value if key == "kaspersky-admin"
  }

  secondary_disk_name        = "space-${local.disk_name_mask}-${each.key}"
  secondary_disk_description = "SPACE-DISK-test-${each.value}"
  secondary_disk_size        = 20
}
