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
  parsed_servers_gitlab_agent   = jsondecode(var.servers_gitlab)
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

data "yandex_compute_disk" "secondary_disk_gitlab_agent" {
  for_each = var.secondary_disk_name != "" ? local.parsed_servers_gitlab_agent : {}
  name     = var.secondary_disk_name != "" ? "hrl-${var.secondary_disk_name}-${each.key}" : ""
}

module "vm-onprem-gitlab" {
  source = "../../../modules/vm"

  for_each = {
    for key, value in local.parsed_servers_gitlab_agent : key => value if key != "regress-release" && !contains(["regress-master"], key)
  }

  name        = "gitlanb-${var.vm_name}-${each.key}"
  hostname    = "gitlab-${var.vm_name}-${each.key}"
  description = "GitLab-agent-${each.value}"
  preemptible = var.preemptible
  nat         = false

  cpu                = 4
  ram                = 12
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
    vm_hostnames = concat(
      [for instance in module.vm-onprem-hrl : instance.hostname],
      [for instance in module.vm-onprem-strl : instance.hostname]
    )

    vm_ips = concat(
      [for instance in module.vm-onprem-hrl : instance.internal_ip],
      [for instance in module.vm-onprem-strl : instance.internal_ip]
    )
    }
  )

  filename = var.vm_hosts_result_file_path

  provisioner "local-exec" {
    command = <<EOH
apt install docker.io
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
apt-get install gitlab-runner
EOH
  }
}
