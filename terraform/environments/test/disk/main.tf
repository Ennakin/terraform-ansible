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
  source = "../../../modules/yandex/disk"

  #   for_each = local.parsed_servers_hrl

  for_each = {
    for key, value in local.parsed_servers_hrl : key => value if key != "stress-1"
  }

  secondary_disk_name        = "hrl-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "HRL-DISK-test-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}

module "disk-hrl-large-ssd" {
  source = "../../../modules/yandex/disk"

  #   for_each = local.parsed_servers_hrl

  for_each = {
    for key, value in local.parsed_servers_hrl : key => value if key == "stress-1"
  }

  secondary_disk_name        = "hrl-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "HRL-DISK-test-${each.value}"
  secondary_disk_size        = 200
  secondary_disk_type        = "network-ssd"
}

module "disk-strl" {
  source = "../../../modules/yandex/disk"

  for_each = local.parsed_servers_strl

  #   for_each = {
  #     for key, value in local.parsed_servers_strl : key => value if key != "kaspersky-admin"
  #   }

  secondary_disk_name        = "strl-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "STRL-DISK-test-${each.value}"
  secondary_disk_size        = var.secondary_disk_size
}

module "disk-space-kaspersky-admin" {
  source = "../../../modules/yandex/disk"

  #   for_each = local.parsed_servers_space

  for_each = {
    for key, value in local.parsed_servers_space : key => value if key == "kaspersky-admin"
  }

  secondary_disk_name        = "space-${var.secondary_disk_name}-${each.key}"
  secondary_disk_description = "SPACE-DISK-test-${each.value}"
  secondary_disk_size        = 20
}
