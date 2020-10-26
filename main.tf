provider "ibm" {
  generation = 2
  region     = var.region
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

# Create a ssh keypair which will be used to provision code onto the system - and also access the VM for debug if needed.
resource tls_private_key "ssh_key_keypair" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

# Create an public/private ssh key pair to be used to login to VMs
resource ibm_is_ssh_key "public_key" {
  name = "${var.project_name}-${var.environment}-public-key"
  public_key = tls_private_key.ssh_key_keypair.public_key_openssh
}

output "ip_address" {
  value = ibm_is_floating_ip.iac_test_floating_ip.address
}

output "ssh_private_key" {
  value = tls_private_key.ssh_key_keypair.private_key_pem
}

# run ansible playbook to install vnc
resource null_resource "run-ansible-vnc" {

  depends_on = [ ibm_is_instance.iac_test_instance ]
  
  provisioner "remote-exec" {
    inline = [ "while [ ! -f '/root/cloudinit.done' ]; do echo 'waiting for userdata to complete...'; sleep 10; done" ]

    connection {
      type        = "ssh"
      user        = "root"
      host        = ibm_is_floating_ip.iac_test_floating_ip.address
      private_key = tls_private_key.ssh_key_keypair.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_key_keypair.private_key_pem}' > privatekey.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 privatekey.pem"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u root -i '${ibm_is_floating_ip.iac_test_floating_ip.address},' --ssh-common-args='-o StrictHostKeyChecking=no' --private-key privatekey.pem playbook/main.yaml" 
  }
}

# if enabled, run ansible playbook to install haproxy
resource null_resource "run-ansible-haproxy" {
  count = var.enable_haproxy ? 1 : 0
  depends_on = [ null_resource.run-ansible-vnc ]

  provisioner "local-exec" {
    command = "ansible-playbook -u root -i '${ibm_is_floating_ip.iac_test_floating_ip.address},' --ssh-common-args='-o StrictHostKeyChecking=no' --private-key privatekey.pem playbook/proxy.yaml" 
  }
}