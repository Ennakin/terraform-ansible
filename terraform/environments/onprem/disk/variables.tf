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

variable "secondary_disk_size" {
  description = "Secondary disk size"
  default     = 40
}
