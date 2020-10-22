#!/bin/sh

#
# apply latest
dnf update -y
dnf install -y NetworkManager

# code to set up the end-user (run in terraform)
useradd -m crcuser
mkdir -p ~crcuser/.ssh
cp /root/.ssh/authorized_keys ~crcuser/.ssh
chown -R crcuser.crcuser ~crcuser/.ssh
chmod -R g-rx,o-rx ~crcuser/.ssh

cat > /etc/sudoers.d/crcuser <<-EOF
## let crcuser do whatever
crcuser    ALL=(ALL)	NOPASSWD: ALL
EOF

# this won't work b/c vnc is not yet installed
# mkdir -p ~crcuser/.vnc
# echo "Vncp8ss#" | vncpasswd -f > ~crcuser/.vnc/passwd
# chmod 600 ~crcuser/.vnc/passwd
# chown -R crcuser.crcuser ~crcuser/.vnc

# touch done file in /root
touch /root/cloudinit.done


