resource "yandex_vpc_subnet" "subnetwork" {
  folder_id      = var.folder_id
  zone           = var.zone
  network_id     = var.network_id
  name           = var.subnetwork_name
  description    = var.subnetwork_description
  v4_cidr_blocks = [var.cidr_v4]
}
