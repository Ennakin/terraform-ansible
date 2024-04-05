variable "secondary_disk_name" {
  description = "Secondary disk name"
}

variable "secondary_disk_description" {
  description = "Secondary disk description"
}

variable "secondary_disk_type" {
  description = "Secondary disk type"
  default     = "network-hdd"
}

variable "secondary_disk_size" {
  description = "Secondary disk size"

  # GB
  default = 8
}
