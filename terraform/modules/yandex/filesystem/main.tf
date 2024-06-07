# создание файлового хранилища
resource "yandex_compute_filesystem" "filesystem" {
  name        = var.filesystem_name
  description = var.filesystem_description
  type        = var.filesystem_type
  size        = var.filesystem_size

  #   labels = {
  #     environment = "test"
  #   }
}
