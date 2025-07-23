resource "google_compute_ssl_policy" "modern_tls" {
  name            = "edge-modern-tls"
  project = module.project_a.project_id
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

module "edge_lb" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 12.0"
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
      protocol    = "HTTPS"
      port_name   = "https"
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

resource "random_id" "neg_suffix" {
  byte_length = 2
  keepers = {
    psc_target_service = data.kubernetes_resource.psc_sa.object["status"]["serviceAttachmentURL"]
  }
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "psc-neg-${random_id.neg_suffix.hex}"
  region                = var.region
  project               = module.project_a.project_id
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = data.kubernetes_resource.psc_sa.object["status"]["serviceAttachmentURL"]
  network               = module.vpc_ext.network_self_link
  subnetwork            = module.vpc_ext.subnets_self_links[1]
}

data "kubernetes_resource" "psc_sa" {
  depends_on = [ time_sleep.wait_for_sa_url ]
  api_version = "networking.gke.io/v1"
  kind       = "ServiceAttachment"
  metadata {
    name      = "envoy-gateway-psc-sa"
    namespace = "envoy-gateway-system"
  }
}

resource "time_sleep" "wait_for_sa_url" {
  depends_on      = [flux_bootstrap_git.flux_bootstrap]
  create_duration = "240s"
}