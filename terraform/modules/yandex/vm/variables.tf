variable "folder_id" {
  description = "VM folder.id"
  default     = ""
}

variable "zone" {
  description = "VM zone"
  default     = ""
}

variable "name" {
  description = "VM name"
}

variable "hostname" {
  description = "VM hostname"
}

variable "description" {
  description = "VM description"
}

variable "platform" {
  description = "VM platform YCloud"
  default     = "standard-v3"
}

variable "preemptible" {
  description = "VM is preemptible?"
  default     = true
}

variable "cpu" {
  description = "VM Count cores"
  default     = 2
}

variable "core_fraction" {
  description = "VM core fraction"
  default     = 100
}

variable "ram" {
  description = "VM count ram in GB"
  default     = 2
}

variable "boot_disk_image_id" {
  description = "VM default image ID"
}

variable "boot_disk_size" {
  description = "VM boot disk size"
  default     = 15
}

variable "secondary_disk_image_id" {
  description = "VM secondary disk image ID"
  default     = ""
}

variable "subnetwork_id" {
  description = "VM subnetwork ID"
}

variable "nat" {
  description = "VM nat network interface?"
  default     = true
}

variable "filesystem_id" {
  description = "VM filesystem ID"
  default     = ""
}

variable "filesystem_device_name" {
  description = "VM filesystem device name"
  default     = ""
}

variable "cloud_config_path" {
  description = "PATH to cloud-config file"
}

