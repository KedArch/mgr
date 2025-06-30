job "srsdu" {
  datacenters = ["cluster"]
  type = "service"

  group "srsdu" {
    count = 1

    constraint {
      attribute = "${meta.region}"
      value     = "edge"
    }
        
    network {
      mode = "bridge"
      port "38472" {
        to = "38472"
      }
      port "2152" {
        to = "2152"
      }
      port "nodeport-2000" {
        static = "2000"
        to = "2000"
      }
    }
    
    task "srsdu" {
      driver = "docker"
      resources {
        cpu = 200
        memory = 4096
      }
      env {
        CU_CP_ADDR = "srscu-f1ap-service"
        UE_ADDR = "{{ hostvars[ue]['ansible_host'] }}"
      }
      config {
        image = "{{ host_internal_ip }}:5000/mgr/srsdu:latest"
        command = "/script.sh"
        force_pull = true
        cap_add = ["net_raw", "net_admin"]
        ports = [
          "38472",
          "2152",
          "nodeport-2000",
        ]
        volumes = [
          "{{ data_dir }}/volumes/scripts/srsdu.sh:/script.sh",
          "{{ data_dir }}/volumes/configs/srsdu.yaml.in:/etc/srsdu.yaml.in"
        ]
      }
    }

    service {
      name = "srsdu-f1ap-service"
      tags = ["clusterip", "internal"]
      port = "38472"
    }
    service {
      name = "srsdu-f1u-service"
      tags = ["clusterip", "internal"]
      port = "2152"
    }
    service {
      name = "srsdu-zmq-node-service"
      tags = ["nodeport", "external"]
      port = "nodeport-2000"
    }
  }
}
