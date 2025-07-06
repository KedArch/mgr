job "srscu" {
  datacenters = ["cluster"]
  type = "service"

  group "srscu" {
    count = 1

    constraint {
      attribute = "${meta.region}"
      value     = "reg"
    }
        
    network {
      mode = "bridge"
      port "38472" {
        to = "38472"
      }
      port "2152" {
        to = "2153"
      }
      port "nodeport-2152" {
        static = "2152"
        to = "2152"
      }
    }
    
    task "srscu" {
      driver = "docker"
      resources {
        cpu = 200
        memory = 4096
      }
      env {
        AMF_ADDR = "{{ hostvars[core]['ansible_host'] }}"
      }
      config {
        image = "{{ host_internal_ip }}:5000/mgr/srscu:latest"
        command = "/script.sh"
        force_pull = true
        cap_add = ["net_raw", "net_admin"]
        ports = [
          "38472",
          "nodeport-2152",
        ]
        volumes = [
          "{{ data_dir }}/volumes/scripts/srscu.sh:/script.sh",
          "{{ data_dir }}/volumes/configs/srscu.yaml.in:/etc/srscu.yaml.in"
        ]
      }
    }

    task "nginx" {
      driver = "docker"
      config {
        image = "docker.io/library/nginx:latest"
        cap_add = ["net_raw", "net_admin"]
        ports = [
          "2152"
        ]
        volumes = [
          "{{ data_dir }}/volumes/configs/nginx.conf:/etc/nginx.conf"
        ]
      }
    }
        
    service {
      name = "srscu-f1ap-service"
      tags = ["clusterip", "internal"]
      port = "38472"
    }
    service {
      name = "srscu-f1u-service"
      tags = ["clusterip", "internal"]
      port = "2153"
    }
    service {
      name = "srscu-core-node-service"
      tags = ["nodeport", "external"]
      port = "nodeport-2152"
    }
  }
}
