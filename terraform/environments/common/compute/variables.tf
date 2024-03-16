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

variable "boot_disk_image_id" {
  default = ""
}
variable "boot_disk_size" {
  default = 15
}

variable "filesystem_name" {
  default = ""
}
variable "filesystem_device_name" {
  default = ""
}

variable "cloud_config_file_path" {
  description = "PATH to cloud-config file"
}

variable "vm_hosts_result_file_path" {
  description = "PATH to inventory result file"
}
