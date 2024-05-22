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
  parsed_servers_gitlab   = jsondecode(var.servers_gitlab)
}

module "disk-gitlab" {
  source = "../../../modules/disk"

  for_each = local.parsed_servers_gitlab

  secondary_disk_name        = "gitlab-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "GITLAB-DISK-agent-${each.value}"
  secondary_disk_size        = 30
}

