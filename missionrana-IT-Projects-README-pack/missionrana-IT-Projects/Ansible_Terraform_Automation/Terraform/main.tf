variable "vsphere_user"{}
variable "vsphere_password"{}

provider "vsphere" {
  # vCenter username
  user = var.vsphere_user
  # vCenter password
  password = var.vsphere_password
  vsphere_server = "192.168.171.208"
 
  allow_unverified_ssl = true
} 

data "vsphere_datacenter" "datacenter" {
  name = "cpsy-350-DC"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = "rp-part-c"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "tm-vm-925767"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 256
  guest_id         = "otherLinux64Guest"
  wait_for_guest_ip_timeout = 0
  wait_for_guest_net_timeout = 0
  network_interface {
  network_id = data.vsphere_network.network.id
  }
  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path	       = "iso/alpine-virt-3.20.2-x86_64.iso"
 
  }
  disk {
    label = "Hard Disk 1"
    size  = 1
  }
}