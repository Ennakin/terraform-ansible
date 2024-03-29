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

data "yandex_vpc_subnet" "subnetwork" {
  name = "${var.subnetwork_name}-private"
}

# sudo mkdir /mnt/$FS_NAME && sudo mount -t virtiofs $FS_NAME /mnt/$FS_NAME
data "yandex_compute_filesystem" "fs" {
  count = var.filesystem_name != "" ? 1 : 0
  name  = var.filesystem_name
}

data "yandex_compute_disk" "secondary_disk" {
  count = var.secondary_disk_name != "" ? var.vm_count : 0
  name  = var.secondary_disk_name != "" ? "${var.secondary_disk_name}-${count.index}" : ""
}

module "vm-test" {
  source = "../../../modules/vm"

  count       = var.vm_count
  name        = "${var.vm_name}-${count.index}"
  hostname    = "${var.vm_name}-${count.index}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = var.ram
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = var.secondary_disk_name != "" ? data.yandex_compute_disk.secondary_disk[count.index].id : ""

  filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs[0].id : ""
  filesystem_device_name = var.filesystem_name != "" ? var.filesystem_device_name : ""
}

module "vm-regress-release" {
  source = "../../../modules/vm"

  count       = 1
  name        = "hrl-regress-release-${count.index}"
  hostname    = "hrl-regress-release-${count.index}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = var.ram
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = var.secondary_disk_name != "" ? data.yandex_compute_disk.secondary_disk[count.index].id : ""

  filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs[0].id : ""
  filesystem_device_name = var.filesystem_name != "" ? var.filesystem_device_name : ""
}

module "vm-regress-master" {
  source = "../../../modules/vm"

  count       = 1
  name        = "hrl-regress-master-${count.index}"
  hostname    = "hrl-regress-master-${count.index}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = var.ram
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.cloud_config_file_path)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = var.secondary_disk_name != "" ? data.yandex_compute_disk.secondary_disk[count.index].id : ""

  filesystem_id          = var.filesystem_name != "" ? data.yandex_compute_filesystem.fs[0].id : ""
  filesystem_device_name = var.filesystem_name != "" ? var.filesystem_device_name : ""
}

# вывод в файл полученных hostname и ip vm-ок
# resource "local_file" "vm_ips" {

#   content = templatefile("${path.module}/inventory.tpl",
#     {
#       vm_hostnames = module.vm.*.hostname
#       vm_ips       = module.vm.*.internal_ip
#     }
#   )

#   filename = var.vm_hosts_result_file_path
# }

resource "local_file" "vm_ips" {

  content = templatefile("${path.module}/inventory.tpl", {
    vm_hostnames = flatten(
      [
        module.vm-test.*.hostname,
        module.vm-regress-release.*.hostname,
        module.vm-regress-master.*.hostname
      ]
    )

    vm_ips = flatten(
      [
        module.vm-test.*.public_ip,
        module.vm-regress-release.*.public_ip,
        module.vm-regress-master.*.public_ip
      ]
    )
    }
  )

  filename = var.vm_hosts_result_file_path
}
