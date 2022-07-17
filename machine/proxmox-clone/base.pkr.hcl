
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_node_name" {
  type    = string
  default = "${env("PROXMOX_NODE_NAME")}"
}

variable "proxmox_password" {
  type      = string
  sensitive = true
  default = "${env("PROXMOX_PASSWORD")}"
}

variable "proxmox_source_template" {
  type = string
}

variable "proxmox_template_name" {
  type    = string
}

variable "proxmox_url" {
  type    = string
  default = "${env("PROXMOX_URL")}"
}

variable "proxmox_user" {
  type    = string
  default = "${env("PROXMOX_USER")}"
}

source "proxmox-clone" "test-cloud-init" {
  insecure_skip_tls_verify = true
  full_clone = true

  template_name = "${var.proxmox_template_name}"
  clone_vm      = "${var.proxmox_source_template}"
  
  os              = "l26"
  cores           = "1"
  memory          = "512"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"
  qemu_agent = true
  task_timeout = "5m"
  ssh_timeout = "10m"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  node          = "${var.proxmox_node_name}"
  username      = "${var.proxmox_user}"
  password      = "${var.proxmox_password}"
  proxmox_url   = "${var.proxmox_url}"
}

build {
  sources = ["source.proxmox-clone.test-cloud-init"]

  provisioner "shell" {
    inline         = ["sudo cloud-init clean"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "sudo apt-get update", 
      "sudo apt-get -y upgrade", 
      "sudo apt-get -y install net-tools",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Packer Template Build -- Complete'"
    ]
  }  
}
