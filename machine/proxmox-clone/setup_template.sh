#!/bin/sh

VMID="9100"

qm destroy $VMID
SRC_IMG="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
IMG_NAME="focal-server-cloudimg-amd64.img"
wget -O $IMG_NAME $SRC_IMG

apt install -y libguestfs-tools
virt-customize --install qemu-guest-agent -a $IMG_NAME

TEMPL_NAME="ubuntu2004-cloud"

MEM="512"
DISK_SIZE="8G"
DISK_STOR="local-lvm"
NET_BRIDGE="vmbr0"
qm create $VMID --name $TEMPL_NAME --memory $MEM --net0 virtio,bridge=$NET_BRIDGE
qm importdisk $VMID $IMG_NAME $DISK_STOR
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $DISK_STOR:vm-$VMID-disk-0
qm set $VMID --ide2 $DISK_STOR:cloudinit
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --ipconfig0 ip=dhcp
#qm resize $VMID scsi0 $DISK_SIZE
qm template $VMID
# Remove downloaded image
rm $IMG_NAME