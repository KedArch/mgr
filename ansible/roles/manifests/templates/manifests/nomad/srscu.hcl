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
        command = "/scripts/srscu.sh"
        force_pull = true
        tty = true
        interactive = true
        cap_add = ["net_raw", "net_admin"]
        ports = [
          "38472",
          "nodeport-2152",
        ]
        volumes = [
          "{{ data_dir }}/volumes/scripts:/scripts",
          "{{ data_dir }}/volumes/configs:/configs"
        ]
      }
    }

    task "udp-proxy" {
      driver = "docker"
      config {
        image = "docker.io/alpine/socat:latest"
        args = [
          "-u",
          "UDP-LISTEN:2153,fork",
          "UDP:localhost:2152"
        ]
        ports = [
          "2152"
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
