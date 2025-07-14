resource "google_compute_ssl_policy" "modern_tls" {
  name            = "edge-modern-tls"
  project = module.project_a.project_id
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

module "edge_lb" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 12.2"
  name    = "edge-lb"
  project = module.project_a.project_id
  network = module.vpc_ext.network_self_link

  load_balancing_scheme	= "EXTERNAL_MANAGED"
  ssl                     = true
  managed_ssl_certificate_domains = ["dashy-gcp.mdch-lab.dev"]
  https_redirect          = true
  quic                    = true
  ssl_policy              = google_compute_ssl_policy.modern_tls.self_link

  backends = {
    default = {
      description = "PSC NEG backend"
      protocol    = "HTTP"
      port_name   = "http"
      groups = [
        {
          group = google_compute_region_network_endpoint_group.psc_neg.id
        }
      ]
      security_policy = google_compute_security_policy.waf.id
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "psc-neg"
  region                = var.region
  project               = module.project_a.project_id
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = data.kubernetes_resource.ingress_sa.object["status"]["serviceAttachmentURL"]
  network               = module.vpc_ext.network_self_link
  subnetwork            = module.vpc_ext.subnets_self_links[1]
  lifecycle {
    create_before_destroy = false
  }
}

data "kubernetes_resource" "ingress_sa" {
  depends_on = [ flux_bootstrap_git.flux_bootstrap ]
  api_version = "networking.gke.io/v1"
  kind       = "ServiceAttachment"
  metadata {
    name      = "nginx-ingress-sa"
    namespace = "ingress-nginx"
  }
}

resource "time_sleep" "wait_for_sa_url" {
  depends_on      = [flux_bootstrap_git.flux_bootstrap]
  create_duration = "320s"
}