# tigervnc crc playbook

## Scope

This is a automated way to install and configure `tigervnc`, turn a machine into a workstation and install [crc][crc] on it so you can connect to it graphically.

## Usage

There are two options for using the playbook(s) provided.

- [Install VNC on an existing host](#install-and-start-vnc-on-a-host)
- [Create a new VM with terraform and install VNC](#create-a-vm-and-install-vnc)

### Install and start VNC on a host

1. Check the [vars.yml](./vars/main.yml) for the defaults, (username is probably _not_ crcuser) and
edit the `hosts` for your target machine.

1. Run the following:

    ```bash
    ansible-playbook -i hosts -u root -k playbook/main.yaml
    ```

    After running the playbook, you'll need to `ssh` in as the user you have set to vnc as. You'll need to run the following to create the password and enable the VNC service.

    ```bash
    vncpasswd
    sudo systemctl start vncserver@:1.service
    sudo systemctl enable vncserver@:1.service
    ```

    Now you should be able to use a [vncviewer][vncviewer] and connect with a destination of `IP:1` with your supplied password.

    After this `crc` will be unpacked in your home directory and you can use `crc start` from the release folder to start up your instance. Pull your secret from Red Hat and you should be off to the races.

#### Security

The default configuration enables direct connections to the VNC ports through iptables rules. If you are running the host for VNC and crc on an Internet-connected system, this is not a good idea. Instead, update the [vars/main.yml](./vars/main.yml) file changing `allowDirect` to false and instead tunnel your VNC connections through ssh using something like:

```console
ssh -L5901:127.0.0.1:5901 youruser@yourhost
```

After the ssh connection is established, direct your vncviewer to destination 127.0.0.1:5901.

#### Tested on

This has been tested and works on:

- CentOS 8

### Create a VM and install VNC

This option will create a Centos 8 based VM using the [IBM Cloud terraform provider][ibm cloud terraform provider]. You can download the current provider from the [releases](https://github.com/IBM-Cloud/terraform-provider-ibm/releases/tag/v1.13.1) page and place it into your `~/.terraform.d/plugins` folder to configure you workstation with the IBM Cloud provider.

Alternatively, you can use the [IBM Cloud Schematics](https://cloud.ibm.com/schematics) service to run the code by providing the path to this repository when configuring the workspace. Either case will require a paid account with IBM Cloud. Note - there is currently a promotion for [IBM Cloud VPC](https://www.ibm.com/cloud/vpc) that provides a $500 credit to paid accounts good for 180 days.

1. Set up variables. If using terraform locally, create a `terraform.tfvars` file and provide labels to be used for the **project-name** and **environment**. Resources will be prefixed with these labels in the form `$project-name-$environment`. For example if you set `project-name=foo` and `environment=bar` then the vm instance will be named `foo-bar-instance`. Review the comments in the `variables.tf` file for the other options to customize the creation of the virtual machine.

   If using Schematics - create a new workspace and point to this repository. Edit the undefined variables for the **project-name** and **environment** and adjust other variables as desired.

1. Run the deployment. For local terraform use:

   ```bash
   terraform plan
   ```

   Verify that the resources being created are as desired. Then start the deployment:

   ```bash
   terraform apply
   ```

   This will take some time but there is a hand-off from terraform to ansible which will happen automatically. If you have something else to do for 20 minutes, now would be a good time to do that.

   For Schematics - click on the **Generate Plan** button to see what will be created by the workspace. If all is as desired, click on the **Apply Plan** button. Again if you have something else to do for 20 minutes, now would be a good time to do that.

1. Use the output to connect to the vm. When running locally, the terraform code will output an `ip_address` and an `ssh_private_key`. Assign the address to an environment variable as `CRCHOST` and then save the private key to a file:

    ```bash
    terraform output -json | jq -r '.ssh_private_key.value' > crchost.pem
    chmod 600 crchost.pem
    ssh -i crchost.pem -L5901:127.0.0.1:5901 crcuser@$CRCHOST
    ```

    For schematics, the output will appear in the logs for the run, but the most simple way to get the output is by using the [IBM Cloud Schematics CLI plugin](https://cloud.ibm.com/docs/schematics?topic=schematics-setup-cli). Log in to IBM Cloud and get the workspace id with:

    ```bash
    ibmcloud schematics workspace list
    Name            ID                               Description                               Status     Frozen
    CRC-bootstrap   CRC-bootstrap-c53e7ea0-9949-42                                             ACTIVE     False
    ```

    Next use the id to get the output (update the example with your workspace id)

    ```bash
    CRCHOST=$(ibmcloud schematics output --id CRC-bootstrap-c53e7ea0-9949-42 --output json \
    | jq -r '.[0].output_values[0].ip_address.value')
    ibmcloud schematics output --id CRC-bootstrap-c53e7ea0-9949-42 --output json \
    | jq -r '.[0].output_values[0].ssh_private_key.value' > crchost.pem
    chmod 600 crchost.pem
    ssh -i crchost.pem -L5901:127.0.0.1:5901 crcuser@$CRCHOST
    ```

1. After connecting, you'll need to run the following to create the password and enable the VNC service.

    ```bash
    vncpasswd
    sudo systemctl start vncserver@:1.service
    sudo systemctl enable vncserver@:1.service
    ```

    Now you should be able to use a [vncviewer][vncviewer] and connect with a destination of `localhost:1` with your supplied password.

    After this `crc` will be unpacked in your home directory and you can use `crc start` from the release folder to start up your instance. Pull your secret from Red Hat and you should be off to the races.

#### Notes on using a VM on IBM Cloud

[Code Ready Containers][crc] uses a virtual machine to provide a ready-to-run single node OpenShift cluster. Normally, you would not usually plan to start/stop a Kubernetes cluster because *bad things happen* but as a simple developer-based experience, this is ok to do with `crc`. All you will need to do is run the `crc stop` command to quiesce the cluster instance. With the cluster stopped, you can stop the VM on IBM Cloud. With VPC VM's when the VM is stopped the hourly instance charges also stop. Storage charges continue, but they are $0.016/hour they won't rack up so quickly. When you want to do more work with `crc`, just restart the instance, ssh back in and run `crc start` and in a few minutes the cluster instance will be ready for further use.

## License & Authors

If you would like to see the detailed LICENCE click [here](./LICENCE).

- Authors: JJ Asghar <awesome@ibm.com> and Tim Robinson <timro@us.ibm.com>

```text
Copyright:: 2020- IBM, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[vncviewer]: https://www.realvnc.com/en/connect/download/viewer/
[crc]: https://github.com/code-ready/crc
[ibm cloud terraform provider]: https://github.com/IBM-Cloud/terraform-provider-ibm
