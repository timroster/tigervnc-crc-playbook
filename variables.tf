# the project name to use for the deployment, this will appear before the environment label
variable "project_name" {}

# the environment name to use for the deployment, this will appear after the project name label
variable "environment" {}

# the IBM Cloud resource group to use for vms that are created
variable "resource_group" {
  default = "Default"
}

# the VPC zone to use for the vm
variable "zone" {
  default = "us-south-1"
}

# the IBM Cloud region to use (note: this must be a VPC-enabled region)
variable "region" {
  default = "us-south"
}

# the compute profile to use for the VM, a 8cpu / 16 GB memory system is minimal for hosting CRC
# for other profiles see: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles . For large profiles,
# increase the resources with the `crc config set` commands for cpus and memory
variable "profile" {
  default = "cx2-8x16"
}

# default to using CentOS 8 based on the current ansible playbooks
variable "image_name" {
  default = "ibm-centos-8-2-minimal-amd64-2"
}

# option to configure haproxy through a playbook to allow web applications running on CRC to be 
# accessible from the Internet. You must use your own domain and create CNAMES to the floating 
# IP address of the vm for this to work. For security reasons, the proxy configuration will drop 
# all incoming connections to crc-apps.testing domain except for the IP address set in the 
# `vars/main.yml` file in the allowIP property
variable "enable_haproxy" {
  type = bool
  default = false
}
