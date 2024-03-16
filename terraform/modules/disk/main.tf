# создание дополнительного диска
resource "yandex_compute_disk" "secondary-disk" {
  name = var.secondary_disk_name
  type = var.secondary_disk_type
  size = var.secondary_disk_size

  #   labels = {
  #     environment = "test"
  #   }
}
