variable "project_name" {}
variable "environment" {}

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

variable "image_name" {
  default = "ibm-centos-8-2-minimal-amd64-1"
}
