packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "ubuntu" {
    # Connection Configuration
    proxmox_url             = "${var.proxmox_url}"
    username                = "${var.proxmox_user}"
    password                = "${var.proxmox_password}"
    insecure_skip_tls_verify    = "true"
    node                    = "${var.proxmox_node}"
    clone_vm                = "${var.proxmox_clone_vm}"
}

build {
  sources = ["source.proxmox-clone.ubuntu" ]

  provisioner "shell" {
    inline = ["echo 'Packer Template Build -- Complete'"]
  }
}    