variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "secondary_disk_name" {}

variable "secondary_disk_size" {
  default = 40
}

variable "servers_gitlab" {
  type    = string
  default = "{1: 'test'}"
}
