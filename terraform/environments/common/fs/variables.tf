variable "main_config" {
  description = "PATH to main config file"
  default     = "../../../conf/infra_main_conf.json"
}

variable "token" {
  description = "Access token for cloud"
}

variable "filesystem_type" {
  description = "Filesystm type"
  default     = "network-hdd"
}
variable "filesystem_size" {
  description = "Filesystem size"
  default     = 30
}
