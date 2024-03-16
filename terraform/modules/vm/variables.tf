variable "name" {
  description = "Name VM"
}

variable "hostname" {
  description = "Hostname VM"
}

variable "platform" {
  description = "Platform YCloud"
  default     = "standard-v1"
}

variable "preemptible" {
  description = "VM is preemptible?"
  default     = true
}

variable "cpu" {
  description = "Count cores"
  default     = 2
}

variable "ram" {
  description = "Count ram in GB"
  default     = 2
}

variable "boot_disk_image_id" {
  description = "ID default image for VM"
}

variable "boot_disk_size" {
  description = "Boot disk size"
  default     = 15
}

variable "secondary_disk_image_id" {
  description = "ID secondary disk image for VM"
  default     = ""
}

variable "subnetwork_id" {
  description = "ID subnetwork for VM"
}

variable "nat" {
  description = "nat network interface?"
  default     = true
}

variable "filesystem_id" {
  description = "ID filesystem"
  default     = ""
}

variable "filesystem_device_name" {
  description = "Filesystem device name"
  default     = ""
}

variable "cloud_config_path" {
  description = "PATH to cloud-config file"
}

