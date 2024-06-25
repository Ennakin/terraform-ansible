variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "secondary_disk_size" {
  default = 40
}

variable "environments_config" {
  description = "PATH to environments config file"
  default     = "../../../json/infra_environments_config.json"
}

variable "servers_and_disks" {
  description = "PATH to servers and disks description file"
  default     = "../../../json/infra_servers_and_disks.json"
}
