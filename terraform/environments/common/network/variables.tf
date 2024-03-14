variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "network_name" {}
variable "subnetwork_name" {}

variable "subnetwork_cidr_v4_private" {
  default = "10.70.0.0/16"
}

variable "subnetwork_cidr_v4_public" {
  default = "10.128.0.0/16"
}
