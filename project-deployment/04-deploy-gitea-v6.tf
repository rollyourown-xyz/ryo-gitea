# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Deploy gitea git server
#########################
##
## Gitea git server for IPv6 host
## With IPv4 and IPv6 proxy devices
##

resource "lxd_container" "gitea-v6" {

  count = ( local.lxd_host_public_ipv6 == true ? 1 : 0 )

  depends_on = [ module.deploy-git-cert-domains, module.deploy-gitea-database-and-user ]

  remote     = var.host_id
  name       = "gitea"
  image      = join("-", [ local.project_id, "gitea", var.image_version ])
  profiles   = ["default"]
  
  config = { 
    "security.privileged": "false"
    "user.user-data" = file("cloud-init/cloud-init-gitea.yml")
  }

  # Provide eth0 interface with dynamic IP address
  device {
    name = "eth0"
    type = "nic"

    properties = {
      name           = "eth0"
      network        = var.host_id
      "ipv4.address" = join(".", [ local.lxd_host_network_part, local.gitea_ip_addr_host_part ])
      "ipv6.address" = join("", [ local.lxd_host_public_ipv6_prefix, "::", local.lxd_host_network_ipv6_subnet, ":", local.gitea_ip_addr_host_part ])
    }
  }

  ## Add proxy device for Gitea SSH interface (IPv4)
  ### TCP Port 3022
  device {
    name = "proxy0"
    type = "proxy"

    properties = {
      listen  = join("", [ "tcp:", local.lxd_host_control_ipv4_address, ":3022" ] )
      connect = join("", [ "tcp:", local.lxd_host_network_part, ".", local.gitea_ip_addr_host_part, ":3022" ] )
      nat     = "yes"
    }
  }

  ## Add proxy device for Gitea SSH interface (IPv6)
  ### TCP Port 3022
  device {
    name = "proxy1"
    type = "proxy"

    properties = {
      listen  = join("", [ "tcp:", "[", local.lxd_host_public_ipv6_address, "]", ":3022" ] )
      connect = join("", [ "tcp:", "[", local.lxd_host_public_ipv6_prefix, "::", local.lxd_host_network_ipv6_subnet, ":", local.gitea_ip_addr_host_part, "]", ":3022" ] )
      nat     = "yes"
    }
  }

  # Mount container directory for persistent storage for gitea configuration
  device {
    name = "gitea-config"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/gitea/config" ])
      path     = "/etc/gitea"
      readonly = "false"
      shift    = "true"
    }
  }

  # Mount container directory for persistent storage for gitea data
  device {
    name = "gitea-data"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/gitea/data" ])
      path     = "/var/lib/gitea"
      readonly = "false"
      shift    = "true"
    }
  } 
}
