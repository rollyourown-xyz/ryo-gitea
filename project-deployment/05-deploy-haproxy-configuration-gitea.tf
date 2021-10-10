# Deploy HAProxy configuration for gitea
########################################

module "deploy-gitea-ssh-haproxy-tcp-listener-configuration" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  haproxy_tcp_listeners = {
    3022 = {service = "gitea-ssh"}
  }
}

module "deploy-gitea-haproxy-backend-service" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-backend-services"

  ssl_backend_services     = [ "gitea-http" ]
}

module "deploy-gitea-http-haproxy-acl-configuration" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-gitea-haproxy-backend-service ]

  haproxy_host_only_acls = {
    host-gitea-http = {host = local.project_git_domain_name}
  }
}

module "deploy-gitea-http-haproxy-backend-configuration" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-gitea-http-haproxy-acl-configuration ]

  haproxy_acl_use-backends = {
    host-gitea-http = {backend_service = "gitea-http"}
  }
}
