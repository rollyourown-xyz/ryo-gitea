# Deploy certbot configuration for project domain and gitea server
##################################################################

module "deploy-git-cert-domains" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-cert-domains"

  certificate_domains = {
    domain_1 = {domain = local.project_domain_name, admin_email = local.project_admin_email},
    domain_2 = {domain = local.project_git_domain_name, admin_email = local.project_admin_email}
  }
}
