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
  parsed_servers_hrl = jsondecode(var.servers_hrl)
  #   parsed_servers_strl  = jsondecode(var.servers_strl)
  #   parsed_servers_space = jsondecode(var.servers_space)
}

# # пока используется подсеть из основной директории
# data "yandex_vpc_subnet" "subnetwork" {
#   name = "${var.subnetwork_name}-private"
# }

# подсеть из другой директории
data "yandex_vpc_subnet" "subnetwork" {
  folder_id = var.folder_id_main_folder
  name      = var.subnetwork_name_main_folder
}

# sudo mkdir /mnt/$FS_NAME && sudo mount -t virtiofs $FS_NAME /mnt/$FS_NAME
# TODO FS один и для HRL, и для STRL
data "yandex_compute_filesystem" "fs_hrl" {
  count = var.filesystem_name != "" ? 1 : 0
  name  = "hrl-${var.filesystem_name}"
}

# # файловое хранилище из другой директории
# data "yandex_compute_filesystem" "fs_hrl" {
#   count     = var.filesystem_name != "" ? 1 : 0
#   folder_id = var.folder_id_main_folder
#   name      = var.filesystem_name_main_folder
# }

data "yandex_compute_disk" "secondary_disk_hrl" {
  for_each = var.secondary_disk_name != "" ? local.parsed_servers_hrl : {}
  name     = var.secondary_disk_name != "" ? "hrl-${var.secondary_disk_name}-${each.key}" : ""
}

# data "yandex_compute_disk" "secondary_disk_strl" {
#   for_each = var.secondary_disk_name != "" ? local.parsed_servers_strl : {}
#   name     = var.secondary_disk_name != "" ? "strl-${var.secondary_disk_name}-${each.key}" : ""
# }

# data "yandex_compute_disk" "secondary_disk_space" {
#   for_each = var.secondary_disk_name != "" ? local.parsed_servers_space : {}
#   name     = var.secondary_disk_name != "" ? "space-${var.secondary_disk_name}-${each.key}" : ""
# }

module "vm-prod-hrl-external-grafana" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.parsed_servers_hrl : key => value if key == "external-grafana"
  }

  name        = "hrl-${var.vm_name}-${each.key}"
  hostname    = "hrl-${var.vm_name}-${each.key}"
  description = "HRL-VM-prod-${each.value}"
  preemptible = false
  nat         = false

  cpu                = 2
  ram                = 4
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = var.secondary_disk_name != "" ? data.yandex_compute_disk.secondary_disk_hrl["external-grafana"].id : ""

  # TODO FS HRL-овский
  filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = var.filesystem_name != "" ? "hrl-${var.filesystem_device_name}" : ""
}

# вывод в файл полученных hostname и ip vm-ок
resource "local_file" "vm_ips" {

  content = templatefile("${path.module}/inventory.tpl", {
    vm_hostnames = concat(
      [for instance in module.vm-prod-hrl-external-grafana : instance.hostname]
    )

    vm_ips = concat(
      [for instance in module.vm-prod-hrl-external-grafana : instance.internal_ip]
    )
    }
  )

  filename = var.vm_hosts_result_file_path
}
