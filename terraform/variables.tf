variable "libvirt_host" {
  description = "Libvirt host for SSH connection"
  type = string
}

variable "libvirt_host_user" {
  description = "Libvirt host user for SSH connection"
  type = string
}

variable "vm_user" {
  description = "Username for VM user"
  type = string
  default = "deploy"
}

variable "vm_user_pass_hash" {
  description = "Password hash for VM user (mkpasswd)"
  type = string
}

variable "vm_user_auth_keys" {
  description = "List of VM user SSH authorized keys"
  type = list(string)
}

variable "vm_subnet" {
  description = "Subnet used by VMS"
  type = string
}

variable "vms" {
  description = "Map of VM configurations with named types as keys"
  type = map(map(object({ # first key is group, group_vars are in seperate var
    vcpu = number
    ram = number
    ip = string
    system_size = optional(number) # it is multiplied by 1024^3
    data_size = number # it is multiplied by 1024^3
    ansible_vars = optional(string) # ansible host_vars
  })))
}

variable "group_vars" {
  description = "Variables for group_vars"
  type = map(object({
    vm_internal_network_interface = optional(string)
    ansible_vars = optional(string)
  }))
  default = {}
}
