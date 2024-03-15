variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "subnetwork_name" {}

variable "cpu" {
  default = 2
}
variable "ram" {
  default = 2
}

variable "preemptible" {
  default = true
}

variable "nat" {
  default = true
}

variable "boot_disk_image_id" {}
variable "boot_disk_size" {
  default = 15
}

variable "filesystem_name" {}
variable "filesystem_device_name" {}

variable "cloud_config_file_path" {
  description = "PATH to cloud-config file"
}

variable "vm_hosts_result_file_path" {
  description = "PATH to inventory result file"
}
