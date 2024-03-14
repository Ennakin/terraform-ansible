resource "yandex_vpc_subnet" "subnetwork" {
  network_id     = var.network_id
  name           = var.subnetwork_name
  v4_cidr_blocks = [var.cidr_v4]
}
