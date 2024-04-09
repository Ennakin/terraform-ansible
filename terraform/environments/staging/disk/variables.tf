variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {}

variable "secondary_disk_name" {}

variable "secondary_disk_size" {
  default = 40
}

variable "servers_hrl" {
  description = "HRL servers to creating"
  default     = "{}"
}

variable "servers_strl" {
  description = "STRL servers to creating"
  default     = "{}"
}
