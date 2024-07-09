variable "main_config" {
  description = "PATH to main config file"
  default     = "../../../conf/main_conf.json"
}

variable "YC_IAM_TOKEN" {
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
