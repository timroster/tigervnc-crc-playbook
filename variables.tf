variable "project_name" {}
variable "environment" {}

variable "ssh_keyname" {
  default = ""
}

variable "resource_group" {
  default = "Default"
}

variable "zone" {
  default = "us-south-1"
}

variable "region" {
  default = "us-south"
}

variable "profile" {
  default = "cx2-2x4"
}

variable "image" {
  default = "r006-f55c2dc3-8420-4dda-948b-9205e3287b74"
}
