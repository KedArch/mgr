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
    "main-2" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.12"
      storage_size = 10
      vars = {
        region = "main"
      }
    }
    "reg-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.21"
      storage_size = 10
      vars = {
        region = "reg"
      }
    }
  }
  "worker" = {
    "main-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.31"
      storage_size = 50
      vars = {
        region = "main"
      }
    }
    "main-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.32"
      storage_size = 50
      vars = {
        region = "main"
      }
    }
    "reg-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.51"
      storage_size = 50
      vars = {
        region = "reg"
      }
    }
    "reg-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.52"
      storage_size = 50
      vars = {
        region = "reg"
      }
    }
    "edge-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.71"
      storage_size = 50
      vars = {
        region = "edge"
      }
    }
    "edge-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.72"
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
group_vars = {
  "all" = {
    "host_internal_ip" = "10.200.0.1"
    "host_vm_network" = "10.200.0.0/16"
    "squid_port" = 3142
    "nginx_port" = 8000
    "data_dir" = "/opt"
    "first_cp_node" = "main-1"
    "cp_node_group" = "control"
    "worker_node_group" = "worker"
  }
  "worker" = {
    "k8s_group_labels" = "['node-role.kubernetes.io/worker=']"
  }
}