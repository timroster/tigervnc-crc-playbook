provider "ibm" {
  generation = 2
  region     = var.region
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_is_ssh_key" "iac_test_key" {
  name = var.ssh_keyname
}

output "ip_address" {
  value = ibm_is_floating_ip.iac_test_floating_ip.address
}

# queue up ansible run
resource null_resource "run-ansible" {

  depends_on = [ ibm_is_instance.iac_test_instance ]
  
  provisioner "remote-exec" {
    inline = [ "while [ ! -f '/root/cloudinit.done' ]; do echo 'waiting for userdata to complete...'; sleep 10; done" ]

    connection {
      type        = "ssh"
      user        = "root"
      host        = ibm_is_floating_ip.iac_test_floating_ip.address
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u root -i '${ibm_is_floating_ip.iac_test_floating_ip.address},' --ssh-common-args='-o StrictHostKeyChecking=no' playbook/main.yaml" 
  }
}
