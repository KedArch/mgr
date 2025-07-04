vm_subnet = "10.200.0.0/24"
vms = {
  "control" = {
    "main-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.11"
      data_size = 10
      vars = {
        region = "main"
        k8s_node_labels = "['node-role.kubernetes.io/main=']"
      }
    }
    "main-2" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.12"
      data_size = 10
      vars = {
        region = "main"
        k8s_node_labels = "['node-role.kubernetes.io/main=']"
      }
    }
    "reg-1" = {
      vcpu = 2
      ram = 4096
      ip = "10.200.0.21"
      data_size = 10
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
      data_size = 50
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
      data_size = 50
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
      data_size = 50
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
      data_size = 50
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
      data_size = 50
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
      data_size = 50
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
      data_size = 10
    }
    "core" = {
      vcpu = 4
      ram = 4096
      ip = "10.200.0.101"
      data_size = 10
      system_size = 15
      vars = {
        region = "reg"
        open5gs = true
      }
    }
    "upf" = {
      vcpu = 2
      ram = 2048
      ip = "10.200.0.102"
      data_size = 10
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
    "tc_latency" = "{'main': {'reg': '100', 'edge': '500'}, 'reg': {'main': '100', 'edge': '10'}, 'edge': {'main': '500', 'reg': '10'}}"
    "vm_internal_network_interface": "ens4"
    "upf" = "other-upf"
    "core" = "other-core"
    "ue" = "other-ue"
  }
  "worker" = {
    "k8s_group_labels" = "['node-role.kubernetes.io/worker=']"
  }
}
