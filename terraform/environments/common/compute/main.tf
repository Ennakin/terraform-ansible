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
  name = "${var.subnetwork_name}-public"
}

data "yandex_compute_filesystem" "fs" {
  name = var.filesystem_name
}

module "vm-reverse-nginx" {
  source = "../../../modules/vm"

  name        = "hrl-reverse-nginx"
  hostname    = "hrl-reverse-nginx"
  preemptible = var.preemptible
  nat         = true

  cpu                = var.cpu
  ram                = var.ram
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file("../../../configs/cloud-config")

  subnetwork_id          = data.yandex_vpc_subnet.subnetwork.id
  filesystem_id          = data.yandex_compute_filesystem.fs.id
  filesystem_device_name = var.filesystem_device_name
}

# вывод в файл полученных hostname и ip vm-ок
resource "local_file" "vm_ips" {

  content = templatefile("${path.module}/inventory.tpl",
    {
      vm_hostnames_reverse = module.vm-reverse-nginx.*.hostname
      vm_ips_reverse       = module.vm-reverse-nginx.*.public_ip
    }
  )

  filename = var.vm_hosts_result_file_path
}

