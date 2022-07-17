terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.0"
    }
  }
}

provider "proxmox" {
    pm_api_url = "https://k8s01.peltops.com:8006/api2/json"
    pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "cp1" {
    name        = "5gcorevm1"
    target_node = "k8s01"
    clone       = "test-output-template"
    cores       = 1
    sockets     = "1"
    cpu         = "host"
    memory      = 4096
    scsihw      = "virtio-scsi-pci"
    bootdisk    = "scsi0"
    disk {
        size            = "40G"
        type            = "scsi"
        storage         = "local-lvm"
    }
    network {
        model           = "virtio"
        bridge          = "vmbr0"
    }
    ipconfig0   = "ip=10.10.10.21/24,gw=10.10.10.1"
    sshkeys     = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC87vq47aAtO2hc3sC2Z8bp8lHzmj8rrvlyz7Cz4PdUZentDGWOxDp8HpSjVHP28XMgqBXjtT+YZ4StVC1sdswn/f/eF3heDk4a/PMTAef1w/R6rPyTWtgq839ru47fq/kNXVBDaECnZ5awitDTk/z1foMGXFXj5h0h37/aEuYw69ONM1M8NDENqQqbndrZVlb/UnJ8DESj0yInDy7dqxSzLD5piTIOGDOF9SaOoAYQjOFYPOIvNEmT0PAp9jQGLML3SxDjFttyP6x77x6gWj9ae3bSlADqmrqjBQONalUoLHBYcNzI1vyOs6BnJpx4lZvNcx+6LASm1mpUF84JKLkZ root@k8s01
    EOF
}
