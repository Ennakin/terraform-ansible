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

# variable "disk_map" {
#   type = map(string)
#   default = {
#     "1" = "one"
#     "2" = "two"
#     "3" = "three"
#   }
# }

# variable "disk_list" {
#   type    = list(string)
#   default = ["one", "two", "three"]
# }
