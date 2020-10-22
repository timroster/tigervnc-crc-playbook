resource "ibm_is_instance" "iac_test_instance" {
  name    = "${var.project_name}-${var.environment}-instance"
  image   = var.image
  resource_group  = data.ibm_resource_group.group.id
  profile = var.profile

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.iac_test_subnet.id
    security_groups = [ibm_is_security_group.iac_test_security_group.id]
  }

  vpc  = ibm_is_vpc.iac_test_vpc.id
  zone = var.zone
  keys      = [ibm_is_ssh_key.public_key.id]

  user_data = file("${path.module}/tfscripts/setup.sh")

  tags = ["iac-${var.project_name}-${var.environment}"]

}
