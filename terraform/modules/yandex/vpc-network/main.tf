resource "yandex_vpc_network" "network" {
  folder_id   = var.folder_id
  name        = var.network_name
  description = var.network_description
}
