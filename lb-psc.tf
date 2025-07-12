resource "google_compute_ssl_policy" "modern_tls" {
  name            = "edge-modern-tls"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

module "edge_lb" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 12.2"

  project = module.project_a.project_id
  name    = "edge-lb"

  ssl                     = true
  managed_ssl_certificate_domains = ["dashy-gcp.mdch-lab.dev"]
  https_redirect          = true
  quic                    = true
  ssl_policy              = google_compute_ssl_policy.modern_tls.self_link

  backends = {
    default = {
      protocol     = "HTTP"
      port         = 80
      security_policy = google_compute_security_policy.waf.id
      enable_cdn = false

      groups = [{
        group                 = google_compute_region_network_endpoint_group.psc_neg.id
        balancing_mode        = "RATE"
        max_rate_per_endpoint = 150
      }]

      health_check = {
        request_path       = "/healthz"
        port               = 80
        check_interval_sec = 10
        timeout_sec        = 5
        healthy_threshold  = 2
        unhealthy_threshold = 3
        logging            = true
      }

      log_config = { enable = true, sample_rate = 1.0 }
    }
  }
}


resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "psc-neg"
  region                = var.region
  project               = module.project_b.project_id
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = data.external.ingress_sa_url.result.url

  subnetwork = module.vpc_int.subnets_names[0]
}

data "external" "ingress_sa_url" {
  depends_on = [ flux_bootstrap_git.flux_bootstrap ]
  program = ["bash", "-c", <<EOT
echo "{\"url\": \"$(kubectl get serviceattachment nginx-ingress-sa -n ingress-nginx -o jsonpath='{.status.serviceAttachmentURL}')\"}"
EOT
  ]
}
