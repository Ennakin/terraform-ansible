resource "yandex_compute_instance" "vm" {
  name        = var.name
  hostname    = var.hostname
  platform_id = var.platform

  allow_stopping_for_update = true

  resources {
    cores         = var.cpu
    core_fraction = 20
    memory        = var.ram
  }

  boot_disk {
    initialize_params {
      image_id = var.boot_disk_image_id
      size     = var.boot_disk_size
    }
  }

  dynamic "secondary_disk" {
    for_each = var.secondary_disk_image_id != "" ? [1] : []
    content {
      disk_id = var.secondary_disk_image_id
    }
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  network_interface {
    subnet_id = var.subnetwork_id
    nat       = var.nat
  }

  # sudo mkdir /mnt/$FS_NAME && sudo mount -t virtiofs $FS_NAME /mnt/$FS_NAME
  dynamic "filesystem" {
    for_each = var.filesystem_id != "" ? [1] : []
    content {
      filesystem_id = var.filesystem_id
      device_name   = var.filesystem_device_name
    }
  }

  metadata = {
    serial-port-enable = 1
    user-data          = var.cloud_config_path
    # user-data          = file("${path.module}/cloud-config")
  }
}
