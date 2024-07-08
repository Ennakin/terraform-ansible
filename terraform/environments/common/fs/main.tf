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

locals {
  parsed_main_config          = jsondecode(data.local_file.main_config.content)
  zone                        = local.parsed_main_config["zone"]
  filesystem_name_mask        = local.parsed_main_config["filesystem-name-mask"]
  filesystem_device_name_mask = local.parsed_main_config["filesystem-device-name-mask"]
  folder_hr_link_tf_id        = local.parsed_main_config["folders"]["folder-hr-link-tf"]["id"]
}

# TODO нужно переделать на space
module "fs-hrl" {
  source = "../../../modules/yandex/filesystem"

  filesystem_name        = "hrl-${local.filesystem_name_mask}"
  filesystem_description = "Файловое хранилище HRL"
  filesystem_size        = var.filesystem_size
}
