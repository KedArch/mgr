vm_subnet = "10.200.0.0/24"
vms = {
  "control" = {
    "main-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.11"
      storage_size = 10
      vars = {
        region = "main"
      }
    }
    "sec-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.12"
      storage_size = 10
      vars = {
        region = "main"
      }
    }
    "sec-2" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.13"
      storage_size = 10
      vars = {
        region = "regional"
      }
    }
  }
  "worker" = {
    "main-cloud-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.51"
      storage_size = 50
      vars = {
        region = "main"
      }
    }
    "main-cloud-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.52"
      storage_size = 50
      vars = {
        region = "main"
      }
    }
    "reg-cloud-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.53"
      storage_size = 50
      vars = {
        region = "regional"
      }
    }
    "reg-cloud-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.54"
      storage_size = 50
      vars = {
        region = "regional"
      }
    }
    "edge-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.55"
      storage_size = 50
      vars = {
        region = "edge"
      }
    }
    "edge-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.56"
      storage_size = 50
      vars = {
        region = "edge"
      }
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
