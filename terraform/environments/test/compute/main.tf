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

data "local_file" "environments_config" {
  filename = var.environments_config
}

data "local_file" "servers_and_disks" {
  filename = var.servers_and_disks
}

locals {
  parsed_main_config          = jsondecode(data.local_file.main_config.content)
  zone                        = local.parsed_main_config["zone"]
  network_name_mask           = local.parsed_main_config["network-name-mask"]
  subnetwork_name_mask        = local.parsed_main_config["subnetwork-name-mask"]
  boot_disk_image_id          = local.parsed_main_config["boot-disk-image-id"]
  filesystem_name_mask        = local.parsed_main_config["filesystem-name-mask"]
  filesystem_device_name_mask = local.parsed_main_config["filesystem-device-name-mask"]
  folder_hr_link_id           = local.parsed_main_config["folders"]["folder-hr-link"]["id"]
  folder_hr_link_network_name = local.parsed_main_config["folders"]["folder-hr-link"]["network-name"]
  folder_hr_link_tf_id        = local.parsed_main_config["folders"]["folder-hr-link-tf"]["id"]

  parsed_environments_config = jsondecode(data.local_file.environments_config.content)
  vm_name_mask               = local.parsed_environments_config["test"]["vm-name-mask"]
  disk_name_mask             = local.parsed_environments_config["test"]["disk-name-mask"]
  inventory_result_path      = local.parsed_environments_config["test"]["vms-hosts-inventory-result-path"]

  parsed_servers_and_disks = jsondecode(data.local_file.servers_and_disks.content)
  servers_and_disks_hrl    = local.parsed_servers_and_disks["hrl"]["test"]
  servers_and_disks_strl   = local.parsed_servers_and_disks["strl"]["test"]
  servers_and_disks_space  = local.parsed_servers_and_disks["space"]["test"]
}

# подсеть из другой директории
data "yandex_vpc_subnet" "subnetwork" {
  folder_id = local.folder_hr_link_id
  name      = local.folder_hr_link_network_name
}

# sudo mkdir /mnt/$FS_NAME && sudo mount -t virtiofs $FS_NAME /mnt/$FS_NAME
# TODO FS один и для HRL, и для STRL
data "yandex_compute_filesystem" "fs_hrl" {
  count = local.filesystem_name_mask != "" ? 1 : 0
  name  = "hrl-${local.filesystem_name_mask}"
}

data "yandex_compute_disk" "secondary_disk_hrl" {
  for_each = local.disk_name_mask != "" ? local.servers_and_disks_hrl : {}
  name     = local.disk_name_mask != "" ? "hrl-${local.disk_name_mask}-${each.key}" : ""
}

data "yandex_compute_disk" "secondary_disk_strl" {
  for_each = local.disk_name_mask != "" ? local.servers_and_disks_strl : {}
  name     = local.disk_name_mask != "" ? "strl-${local.disk_name_mask}-${each.key}" : ""
}

data "yandex_compute_disk" "secondary_disk_space" {
  for_each = local.disk_name_mask != "" ? local.servers_and_disks_space : {}
  name     = local.disk_name_mask != "" ? "space-${local.disk_name_mask}-${each.key}" : ""
}

module "vm-test-hrl" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key != "regress-release" && !contains(["regress-master", "stress-1", "stress-services"], key)
  }

  name        = "hrl-${local.vm_name_mask}-${each.key}"
  hostname    = "hrl-${local.vm_name_mask}-${each.key}"
  description = "HRL-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = 24
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_hrl[each.key].id : ""

  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

module "vm-test-hrl-stress" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key == "stress-1"
  }

  name        = "hrl-${local.vm_name_mask}-${each.key}"
  hostname    = "hrl-${local.vm_name_mask}-${each.key}"
  description = "HRL-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = 24
  ram                = 48
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_hrl[each.key].id : ""

  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

module "vm-test-hrl-stress-services" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key == "stress-services"
  }

  name        = "hrl-${local.vm_name_mask}-${each.key}"
  hostname    = "hrl-${local.vm_name_mask}-${each.key}"
  description = "HRL-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = 16
  ram                = 32
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_hrl[each.key].id : ""

  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

module "vm-regress-release-hrl" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key == "regress-release"
  }

  name        = "hrl-${local.vm_name_mask}-${each.key}"
  hostname    = "hrl-${local.vm_name_mask}-${each.key}"
  description = "HRL-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = 24
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_hrl["regress-release"].id : ""

  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

module "vm-regress-master-hrl" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_hrl : key => value if key == "regress-master"
  }

  name        = "hrl-${local.vm_name_mask}-${each.key}"
  hostname    = "hrl-${local.vm_name_mask}-${each.key}"
  description = "HRL-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = var.cpu
  ram                = 24
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_hrl["regress-master"].id : ""

  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

module "vm-test-strl" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_strl : key => value if key != "regress-release" && !contains(["regress-master"], key)
  }

  name        = "strl-${local.vm_name_mask}-${each.key}"
  hostname    = "strl-${local.vm_name_mask}-${each.key}"
  description = "STRL-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = 4
  ram                = 12
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_strl[each.key].id : ""

  # TODO FS HRL-овский
  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

module "vm-test-space-kaspersky-admin" {
  source = "../../../modules/yandex/vm"

  for_each = {
    for key, value in local.servers_and_disks_space : key => value if key == "kaspersky-admin"
  }

  name        = "space-${local.vm_name_mask}-${each.key}"
  hostname    = "space-${local.vm_name_mask}-${each.key}"
  description = "SPACE-VM-test-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = 4
  ram                = 8
  boot_disk_image_id = local.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  cloud_config_path  = file(var.CLOUD_CONFIG)

  subnetwork_id           = data.yandex_vpc_subnet.subnetwork.id
  secondary_disk_image_id = local.disk_name_mask != "" ? data.yandex_compute_disk.secondary_disk_space["kaspersky-admin"].id : ""

  # TODO FS HRL-овский
  filesystem_id          = local.filesystem_name_mask != "" ? data.yandex_compute_filesystem.fs_hrl[0].id : ""
  filesystem_device_name = local.filesystem_name_mask != "" ? "hrl-${local.filesystem_device_name_mask}" : ""
}

# вывод в файл полученных hostname и ip vm-ок
resource "local_file" "vm_ips" {

  content = templatefile("${path.module}/inventory.tpl", {
    vm_hostnames = concat(
      [for instance in module.vm-test-hrl : instance.hostname],
      [for instance in module.vm-test-hrl-stress : instance.hostname],
      [for instance in module.vm-test-hrl-stress-services : instance.hostname],
      [for instance in module.vm-regress-release-hrl : instance.hostname],
      [for instance in module.vm-regress-master-hrl : instance.hostname],
      [for instance in module.vm-test-strl : instance.hostname],
      [for instance in module.vm-test-space-kaspersky-admin : instance.hostname]
    )

    vm_ips = concat(
      [for instance in module.vm-test-hrl : instance.internal_ip],
      [for instance in module.vm-test-hrl-stress : instance.internal_ip],
      [for instance in module.vm-test-hrl-stress-services : instance.internal_ip],
      [for instance in module.vm-regress-release-hrl : instance.internal_ip],
      [for instance in module.vm-regress-master-hrl : instance.internal_ip],
      [for instance in module.vm-test-strl : instance.internal_ip],
      [for instance in module.vm-test-space-kaspersky-admin : instance.internal_ip]
    )
    }
  )

  filename = local.inventory_result_path
}
