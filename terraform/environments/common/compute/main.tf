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

# # пока используется подсеть из основной директории
# data "yandex_vpc_subnet" "subnetwork" {
#   name = "${var.subnetwork_name}-public"
# }

data "yandex_vpc_subnet" "subnetwork" {
  folder_id = var.folder_id_main_folder
  name      = var.subnetwork_name_main_folder
}

# sudo mkdir /mnt/$FS_NAME && sudo mount -t virtiofs $FS_NAME /mnt/$FS_NAME
data "yandex_compute_filesystem" "fs" {
  count = var.filesystem_name != "" ? 1 : 0
  name  = var.filesystem_name
}

# module "vm-open-vpn" {
#   source = "../../../modules/vm"

#   name        = "hrl-open-vpn"
#   hostname    = "hrl-open-vpn"
#   preemptible = var.preemptible
#   nat         = true

#   cpu                = var.cpu
#   ram                = var.ram
#   boot_disk_image_id = var.boot_disk_image_id
#   boot_disk_size     = var.boot_disk_size
#   cloud_config_path  = file(var.cloud_config_file_path)

#   subnetwork_id          = data.yandex_vpc_subnet.subnetwork.id
#   filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs[0].id : ""
#   filesystem_device_name = var.filesystem_name != "" ? var.filesystem_device_name : ""
# }

module "vm-reverse-nginx" {
  source = "../../../modules/vm"

  name        = "hrl-reverse-nginx"
  hostname    = "hrl-reverse-nginx"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = var.ram
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id          = data.yandex_vpc_subnet.subnetwork.id
  filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs[0].id : ""
  filesystem_device_name = var.filesystem_name != "" ? var.filesystem_device_name : ""
}

# вывод в файл полученных hostname и ip vm-ок
resource "local_file" "vm_ips" {

  content = templatefile("${path.module}/inventory.tpl", {
    vm_hostnames = flatten(
      [
        # module.vm-open-vpn.*.hostname,
        module.vm-reverse-nginx.*.hostname
      ]
    )

    vm_ips = flatten(
      [
        # module.vm-open-vpn.*.internal_ip,
        module.vm-reverse-nginx.*.internal_ip
      ]
    )
    }
  )

  filename = var.vm_hosts_result_file_path
}
