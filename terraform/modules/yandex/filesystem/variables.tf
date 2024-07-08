variable "folder_id" {
  description = "Filesystem folder.id"
  default     = ""
}

variable "zone" {
  description = "Filesystem zone"
  default     = ""
}

variable "filesystem_name" {
  description = "Filesystem name"
}

variable "filesystem_description" {
  description = "Filesystem description"
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
