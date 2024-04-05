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

module "fs-hrl" {
  source = "../../../modules/filesystem"

  filesystem_name        = "hrl-${var.filesystem_name}"
  filesystem_description = "Файловое хранилище HRL"
  filesystem_size        = var.filesystem_size
}
