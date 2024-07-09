variable "main_config" {
  description = "PATH to main config file"
  default     = "../../../conf/main_conf.json"
}

variable "environments_config" {
  description = "PATH to environments config file"
  default     = "../../../conf/environments_conf.json"
}

variable "servers_and_disks" {
  description = "PATH to servers and disks description file"
  default     = "../../../conf/servers_and_disks.json"
}

variable "YC_IAM_TOKEN" {
  description = "Access token for cloud"
}

variable "CLOUD_CONFIG" {
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
