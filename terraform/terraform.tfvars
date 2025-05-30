vm_subnet = "10.200.0.0/24"
vms = {
  "control" = {
    "main-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.11"
      storage_size = 10
    }
    "sec-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.12"
      storage_size = 10
    }
    "sec-2" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.13"
      storage_size = 10
    }
  }
  "worker" = {
    "main-cloud-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.51"
      storage_size = 50
    }
    "main-cloud-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.52"
      storage_size = 50
    }
    "reg-cloud-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.53"
      storage_size = 50
    }
    "reg-cloud-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.54"
      storage_size = 50
    }
    "edge-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.55"
      storage_size = 50
    }
    "edge-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.56"
      storage_size = 50
    }
  }
  "other" = {
    "ue" = {
      vcpu = 2
      ram = 2048
      ip = "10.200.0.101"
      storage_size = 10
    }
  }
}
