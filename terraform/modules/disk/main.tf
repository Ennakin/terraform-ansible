# создание дополнительного диска
resource "yandex_compute_disk" "secondary-disk" {
  name        = var.secondary_disk_name
  description = var.secondary_disk_description
  type        = var.secondary_disk_type
  size        = var.secondary_disk_size

  #   labels = {
  #     environment = "test"
  #   }
}
