# Deploy gitea git server
#########################

resource "lxd_container" "gitea" {

  depends_on = [ module.deploy-gitea-database-and-user ]

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
