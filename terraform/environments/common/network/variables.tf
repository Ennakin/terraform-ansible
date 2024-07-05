variable "main_config" {
  description = "PATH to main config file"
  default     = "../../../conf/infra_main_conf.json"
}

variable "YC_IAM_TOKEN" {
  description = "Access token for cloud"
}

variable "subnetwork_cidr_v4_private" {
  default = "10.70.0.0/16"
}

variable "subnetwork_cidr_v4_public" {
  default = "10.128.0.0/16"
}
