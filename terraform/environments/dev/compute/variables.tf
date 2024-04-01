variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "subnetwork_name" {}

variable "cpu" {
  default = 6
}
variable "ram" {
  default = 18
}

variable "preemptible" {
  default = true
}

variable "nat" {
  default = false
}

variable "boot_disk_image_id" {}
variable "boot_disk_size" {
  default = 50
}

variable "secondary_disk_name" {
  default = ""
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

variable "vm_name" {}
variable "vm_count" {}

# переменные основной директории
variable "folder_id_main_folder" {}
variable "subnetwork_name_main_folder" {}
