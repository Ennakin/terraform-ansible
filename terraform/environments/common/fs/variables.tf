variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "filesystem_name" {}
variable "filesystem_type" {
  default = "network-hdd"
}
variable "filesystem_size" {
  default = 2
}
