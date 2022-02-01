# Deploy gitea git server
#########################

resource "lxd_container" "gitea" {

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
    }
  }

  ## Add proxy device for Gitea SSH interface
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

  # Mount container directory for persistent storage for synapse configuration
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

  # Mount container directory for persistent storage for synapse data
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
