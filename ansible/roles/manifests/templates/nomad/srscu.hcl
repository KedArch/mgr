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
      config {
        image = "{{ host_internal_ip }}:5000/srscu:latest"
        force_pull = true
        ports = [
          "38472",
          "nodeport-2152",
        ]
      }

      volume_mount {
        volume      = "script"
        destination = "/script.sh"
      }
      volume_mount {
        volume      = "config-in"
        destination = "/etc/srscu.yaml.in"
      }
    }

    task "nginx" {
      driver = "docker"
      config {
        image = "docker.io/library/nginx:latest"
        ports = [
          "2152",
        ]
      }

      volume_mount {
        volume      = "nginx"
        destination = "/etc/nginx.conf"
      }
    }

    volume "script" {
      type = "host"
      source = "{{ data_dir }}/volumes/scripts/srscu.sh"
    }
    volume "config-in" {
      type = "host"
      source = "{{ data_dir }}/volumes/configs/srscu.yaml.in"
    }
    volume "nginx" {
      type = "host"
      source = "{{ data_dir }}/volumes/configs/nginx.conf"
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
