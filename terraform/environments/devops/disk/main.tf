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
  parsed_servers = jsondecode(var.servers)
}

module "disk-hrl" {
  source = "../../../modules/disk"

  for_each = local.parsed_servers

  secondary_disk_name        = "hrl-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "HRL-DISK-devops-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}
