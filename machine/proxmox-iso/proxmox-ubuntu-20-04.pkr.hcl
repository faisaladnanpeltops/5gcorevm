packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox" "ubuntu" {
    # Connection Configuration
    proxmox_url             = "${var.proxmox_url}"
    username                = "${var.proxmox_user}"
    password                = "${var.proxmox_password}"
    insecure_skip_tls_verify    = "true"
    node                    = "${var.proxmox_node}"

    # Location Configuration
    vm_name                 = "${var.vm_name_ubuntu}"
    vm_id                   = "191"

    # Hardware Configuration
    sockets                 = "${var.vm_cpu_sockets}"
    cores                   = "${var.vm_cpu_cores}"
    memory                  = "${var.vm_mem_size}"
    cpu_type                = "${var.vm_cpu_type}"

    # Boot Configuration
    http_interface         = "vmbr0"
    http_port_min          = "8003"
    http_port_max          = "8003"
    boot_command           = [
      "<esc><wait><esc><wait><f6><wait><esc><wait>",
      "<bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs>",
      "<bs><bs><bs>",            
      "initrd=/casper/initrd quiet --- ",      
      "autoinstall net.ifnames=0 biosdevname=0 ip=dhcp ds=nocloud-net;s=http://{{ .HTTPIP }}:8003/ --- ",
      "<enter>"
    ]
    boot_wait              = "3s"
    
    # Http directory Configuration
    http_directory         = "ubuntu/http"

    # ISO Configuration
    iso_checksum            = "file:https://releases.ubuntu.com/releases/focal/SHA256SUMS"
    iso_file                = "local:iso/ubuntu-20.04.4-live-server-amd64.iso"
    #iso_url                 = "https://releases.ubuntu.com/releases/focal/ubuntu-20.04.4-live-server-amd64.iso"
    #iso_storage_pool        = "local"

    # VM Configuration#
    os                     = "l26"

    network_adapters {
        model               = "${var.vm_network_adapters_model}"
        bridge              = "${var.vm_network_adapters_bridge}"
    }

    disks {
        storage_pool      = "local-lvm"
        storage_pool_type = "lvm-thin"
        type              = "scsi"
        disk_size         = "${var.vm_os_disk_size}"
        cache_mode        = "none"
        format            = "qcow2"
    }

    template_name         = "${var.vm_name_ubuntu}"
    template_description  = ""
    unmount_iso           = "true"
    qemu_agent            = "true"

    # Communicator Configuration
    communicator           = "ssh"
    ssh_username           = "ubuntu"
    ssh_password           = "${var.admin_password}"
    ssh_handshake_attempts = "20"
    ssh_timeout           = "1h30m"

}

build {
  sources = ["source.proxmox.ubuntu" ]

  provisioner "shell" {
    environment_vars: ["DEBIAN_FRONTEND=noninteractive"],
    inline = [
      "sudo apt-get update", 
      "sudo apt-get -y upgrade", 
      "sudo apt-get -y install net-tools",
    ]
  }

  provisioner "shell" {
    inline = [
      "wget -q https://go.dev/dl/go1.17.8.linux-amd64.tar.gz", 
      "sudo tar -C /usr/local -xzf go1.17.8.linux-amd64.tar.gz", 
      "sudo echo \"export PATH=$PATH:/usr/local/go/bin\" >> $HOME/.profile",
      "/usr/local/go/bin/go version"
    ]
  }  

  provisioner "shell" {
    inline = [
      "echo 'Packer Template Build -- Complete'"
    ]
  }
}