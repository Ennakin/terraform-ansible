variable "main_config" {
  description = "PATH to main config file"
  default     = "../../../conf/infra_main_conf.json"
}

variable "environments_config" {
  description = "PATH to environments config file"
  default     = "../../../conf/infra_environments_conf.json"
}

variable "servers_and_disks" {
  description = "PATH to servers and disks description file"
  default     = "../../../conf/infra_servers_and_disks.json"
}

variable "token" {
  description = "Access token for cloud"
}

variable "secondary_disk_size" {
  description = "Secondary disk size"
  default     = 40
}
