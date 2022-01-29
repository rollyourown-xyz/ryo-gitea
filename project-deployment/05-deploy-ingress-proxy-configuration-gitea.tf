# Deploy Ingress Proxy configuration for gitea
##############################################

## The Ingress Proxy TCP listener is currently bypassed by a proxy device on the
## gitea container
# module "deploy-gitea-ssh-ingress-proxy-tcp-listener-configuration" {
#   source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

#   depends_on = [ lxd_container.gitea ]

#   ingress-proxy_tcp_listeners = {
#     3022 = {service = "gitea-ssh"}
#   }
# }

module "deploy-gitea-ingress-proxy-backend-service" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"

  depends_on = [ lxd_container.gitea ]

  non_ssl_backend_services     = [ "gitea-http" ]
}

module "deploy-gitea-http-ingress-proxy-acl-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-gitea-ingress-proxy-backend-service ]

  ingress-proxy_host_only_acls = {
    host-gitea-http = {host = local.project_domain_name}
  }
}

module "deploy-gitea-http-ingress-proxy-backend-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-gitea-http-ingress-proxy-acl-configuration ]

  ingress-proxy_acl_use-backends = {
    host-gitea-http = {backend_service = "gitea-http"}
  }
}
