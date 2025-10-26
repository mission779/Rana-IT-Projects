variable "vsphere_user"{}
variable "vsphere_password"{}

provider "vsphere" {
  user = var.vsphere_user
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

variable "hosts" {
  default = [
    "192.168.171.207",
    "192.168.171.211",
  ]
}

data "vsphere_host" "host" {
  for_each      = toset(var.hosts)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "iac-cluster"
  datacenter_id   = data.vsphere_datacenter.datacenter.id
  host_system_ids = [for host in data.vsphere_host.host : host.id]
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  ha_enabled = true
}
resource "vsphere_resource_pool" "resource_pool" {
  name                    = "resource-pool-925767"
  parent_resource_pool_id = resource.vsphere_compute_cluster.compute_cluster.resource_pool_id
	
}
resource "vsphere_nas_datastore" "datastore" {
  name            = "tf-nfs-ds-925767"
  host_system_ids = [for host in data.vsphere_host.host : host.id]

  type         = "NFS"
  remote_hosts = ["192.168.171.210"]
  remote_path  = "/srv/nfsroot"
}