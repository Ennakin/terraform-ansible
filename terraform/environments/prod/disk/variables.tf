variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "secondary_disk_name" {}

variable "secondary_disk_size" {
  default = 40
}

variable "servers_hrl" {
  type    = string
  default = "{}"
}

variable "servers_strl" {
  type    = string
  default = "{}"
}

variable "servers_space" {
  type    = string
  default = "{}"
}
