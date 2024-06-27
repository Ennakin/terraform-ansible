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

variable "cloud_config_file_path" {
  description = "PATH to cloud-config file"
}

variable "cpu" {
  default = 6
}
variable "ram" {
  default = 18
}

variable "preemptible" {
  default = true
}

variable "nat" {
  default = false
}

variable "boot_disk_size" {
  default = 30
}
