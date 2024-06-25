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
  servers_hrl              = local.parsed_servers_and_disks["hrl"]["prod"]

  parsed_environments_config = jsondecode(data.local_file.environments_config.content)
  vm_name_mask               = local.parsed_environments_config["prod"]["vm-name-mask"]
  disk_name_mask             = local.parsed_environments_config["prod"]["disk-name-mask"]
  inventory_result_path      = local.parsed_environments_config["prod"]["vms-hosts-inventory-result-path"]
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

data "yandex_compute_disk" "secondary_disk_hrl" {
  for_each = local.disk_name_mask != "" ? local.servers_hrl : {}
  name     = local.disk_name_mask != "" ? "hrl-${local.disk_name_mask}-${each.key}" : ""
}

module "vm-prod-hrl-external-grafana" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_hrl : key => value if key == "external-grafana"
  }

  name        = "hrl-${local.vm_name_mask}-${each.key}"
  hostname    = "hrl-${local.vm_name_mask}-${each.key}"
  description = "HRL-VM-prod-${each.value}"
  preemptible = false
  nat         = false

  cpu                = 2
  ram                = 4
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_hrl["external-grafana"].id : ""

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

  filename = local.inventory_result_path
}
