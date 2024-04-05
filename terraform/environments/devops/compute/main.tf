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
data "yandex_compute_filesystem" "fs_hrl" {
  count = var.filesystem_name != "" ? 1 : 0
  name  = "hrl-${var.filesystem_name}"
}

data "yandex_compute_disk" "secondary_disk_hrl" {
  for_each = var.secondary_disk_name != "" ? local.parsed_servers : {}
  name     = var.secondary_disk_name != "" ? "hrl-${var.secondary_disk_name}-${each.key}" : ""
}

module "vm-devops-hrl" {
  source = "../../../modules/vm"

  for_each = local.parsed_servers

  name        = "hrl-${var.vm_name}-${each.key}"
  hostname    = "hrl-${var.vm_name}-${each.key}"
  description = "HRL-VM-devops-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = var.ram
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = var.secondary_disk_name != "" ? data.yandex_compute_disk.secondary_disk_hrl[each.key].id : ""

  filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = var.filesystem_name != "" ? "hrl-${var.filesystem_device_name}" : ""
}


# вывод в файл полученных hostname и ip vm-ок
resource "local_file" "vm_ips" {

  content = templatefile("${path.module}/inventory.tpl", {
    vm_hostnames = flatten(
      [
        for instance in module.vm-devops-hrl : instance.hostname
      ]
    )

    vm_ips = flatten(
      [
        for instance in module.vm-devops-hrl : instance.internal_ip
      ]
    )
    }
  )

  filename = var.vm_hosts_result_file_path
}

# # простейший вариант
# resource "local_file" "vm_ips" {

#   content = templatefile("${path.module}/inventory.tpl",
#     {
#       vm_hostnames = module.vm-devops-hrl.*.hostname
#       vm_ips       = module.vm-devops-hrl.*.internal_ip
#     }
#   )

#   filename = var.vm_hosts_result_file_path
# }

# # вариант при использовании count, а не for_each 
# resource "local_file" "vm_ips" {

#   content = templatefile("${path.module}/inventory.tpl", {
#     vm_hostnames = flatten(
#       [
#         module.vm-devops-hrl.*.hostname
#       ]
#     )

#     vm_ips = flatten(
#       [
#         module.vm-devops-hrl.*.internal_ip
#       ]
#     )
#     }
#   )

#   filename = var.vm_hosts_result_file_path
# }
