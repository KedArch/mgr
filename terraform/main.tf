terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = ">= 0.6.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://${var.libvirt_host_user}@${var.libvirt_host}/system?sshauth=privkey"
}

locals {
  vms = merge(flatten([
    for group, vms in var.vms : merge( { for vm, config in vms : "${group}-${vm}" => config } )
  ])...)

  cloud_init_configs = {
    for vm, config in local.vms: vm => templatefile("${path.module}/cloud-init/cloud_init.cfg.tftpl", {
      hostname = vm
      username = var.vm_user
      password_hash = var.vm_user_pass_hash
      auth_keys = var.vm_user_auth_keys
    })
  }

  meta_data_configs = {
    for vm, config in local.vms: vm => templatefile("${path.module}/cloud-init/meta-data.tftpl", {
      hostname = vm
    })
  }

  network_configs = {
    for vm, config in local.vms: vm => templatefile("${path.module}/cloud-init/network.yaml.tftpl", {
      ip = config.ip
      vm_internal_network_interface = var.group_vars.all.vm_internal_network_interface
    })
  }
}

resource "libvirt_network" "internal" {
  name = "internal"
  mode = "open"
  domain = "mgr.local"
  addresses = [var.vm_subnet]
}

resource "libvirt_pool" "cloud_init" {
  name = "cloud_init"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/cloud_init"
  }
}

resource "libvirt_pool" "system" {
  name = "system"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/system"
  }
}

resource "libvirt_pool" "data" {
  name = "data"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/data"
  }
}

resource "libvirt_cloudinit_disk" "init" {
  for_each = local.vms

  name = "${each.key}-init.iso"
  pool = libvirt_pool.cloud_init.name
  user_data = local.cloud_init_configs[each.key]
  meta_data = local.meta_data_configs[each.key]
  network_config = local.network_configs[each.key]
}

resource "libvirt_volume" "base_image" {
  name = "base-image.qcow2"
  pool = "default"
  format = "qcow2"
  lifecycle {
    prevent_destroy = true
  }
}

resource "libvirt_volume" "system" {
  for_each = local.vms

  name = "${each.key}.qcow2"
  pool = libvirt_pool.system.name
  base_volume_id = libvirt_volume.base_image.id
  format = "qcow2"
}

resource "libvirt_volume" "data" {
  for_each = local.vms

  name = "${each.key}-data.qcow2"
  pool = libvirt_pool.data.name
  format = "qcow2"
  size = each.value.storage_size * 1024 * 1024 * 1024
}

resource "libvirt_domain" "vm" {
  for_each = local.vms

  name = each.key
  vcpu = each.value.vcpu
  memory = each.value.ram
  cloudinit = libvirt_cloudinit_disk.init[each.key].id

  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }

  disk {
    volume_id = libvirt_volume.system[each.key].id
  }

  disk {
    volume_id = libvirt_volume.data[each.key].id
  }

  graphics {
    type = "vnc"
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.internal.id
    wait_for_lease = false
    hostname = each.key
  }
}

resource "local_file" "ansible_inventory_file" {
  content = templatefile("${path.module}/inventory_file.yml.tftpl",
    {
      vms = var.vms
      host = var.libvirt_host
      host_user = var.libvirt_host_user
      username = var.vm_user
    }
  )
  filename = "../ansible/inventory/hosts"
}

resource "local_file" "ansible_host_vars_files" {
  for_each = local.vms

  content = templatefile("${path.module}/vars.yml.tftpl",
    {
      vars = try(each.value.vars, {})
    }
  )
  filename = "../ansible/inventory/host_vars/${each.key}.yml"
}

resource "local_file" "ansible_group_vars_files" {
  for_each = var.group_vars
  content = templatefile("${path.module}/vars.yml.tftpl",
    {
      vars = try(each.value, {})
    }
  )
  filename = "../ansible/inventory/group_vars/${each.key}.yml"
}