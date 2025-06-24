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
        k8s_node_labels = "['node-role.kubernetes.io/main=']"
      }
    }
    "main-2" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.12"
      storage_size = 10
      vars = {
        region = "main"
        k8s_node_labels = "['node-role.kubernetes.io/main=']"
      }
    }
    "reg-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.21"
      storage_size = 10
      vars = {
        region = "reg"
        k8s_node_labels = "['node-role.kubernetes.io/reg=']"
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
        k8s_node_labels = "['node-role.kubernetes.io/main=']"
        nomad_node_meta = "{'region': 'main'}"
      }
    }
    "main-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.32"
      storage_size = 50
      vars = {
        region = "main"
        k8s_node_labels = "['node-role.kubernetes.io/main=']"
        nomad_node_meta = "{'region': 'main'}"
      }
    }
    "reg-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.51"
      storage_size = 50
      vars = {
        region = "reg"
        k8s_node_labels = "['node-role.kubernetes.io/reg=']"
        nomad_node_meta = "{'region': 'reg'}"
      }
    }
    "reg-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.52"
      storage_size = 50
      vars = {
        region = "reg"
        k8s_node_labels = "['node-role.kubernetes.io/reg=']"
        nomad_node_meta = "{'region': 'reg'}"
      }
    }
    "edge-1" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.71"
      storage_size = 50
      vars = {
        region = "edge"
        k8s_node_labels = "['node-role.kubernetes.io/edge=']"
        nomad_node_meta = "{'region': 'edge'}"
      }
    }
    "edge-2" = {
      vcpu = 4
      ram = 8192
      ip = "10.200.0.72"
      storage_size = 50
      vars = {
        region = "edge"
        k8s_node_labels = "['node-role.kubernetes.io/edge=']"
        nomad_node_meta = "{'region': 'edge'}"
      }
    }
  }
  "other" = {
    "ue" = {
      vcpu = 2
      ram = 2048
      ip = "10.200.0.111"
      storage_size = 10
    }
    "core" = {
      vcpu = 4
      ram = 4096
      ip = "10.200.0.101"
      storage_size = 10
      vars = {
        region = "reg"
        open5gs = true
      }
    }
    "upf" = {
      vcpu = 2
      ram = 2048
      ip = "10.200.0.102"
      storage_size = 10
      vars = {
        region = "edge"
        open5gs = true
      }
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
    "first_cp_node" = "control-main-1"
    "cp_node_group" = "control"
    "worker_node_group" = "worker"
    "tc_latency" = "{'main': {'reg': '1000', 'edge': '2500'}, 'reg': {'main': '1000', 'edge': '400'}, 'edge': {'main': '2500', 'reg': '400'}}"
    "vm_internal_network_interface": "ens4"
  }
  "worker" = {
    "k8s_group_labels" = "['node-role.kubernetes.io/worker=']"
  }
  "other" = {
    upf = "other-upf"
    core = "other-core"
    ue = "other-ue"
  }
}