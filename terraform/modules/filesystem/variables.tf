variable "filesystem_name" {
  description = "Filesystem name"
}

variable "filesystem_type" {
  description = "Filesystm type"
  default     = "network-hdd"
}

variable "filesystem_size" {
  description = "Filesystem size"

  # GB
  default = 2
}
