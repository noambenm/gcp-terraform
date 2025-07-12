data "google_compute_service_attachment" "ingress_sa" {
  name    = "nginx-ingress-sa"
  region  = var.region
  project = module.project_b.project_id
}

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

  # ── Front end ──────────────────────────────────────────────────────
  ssl                     = true
  managed_ssl_certificate_domains = ["mdch-lab.dev", "*.mdch-lab.dev"]
  https_redirect          = true
  quic                    = true
  ssl_policy              = google_compute_ssl_policy.modern_tls.self_link

  # ── Back end (PSC) ─────────────────────────────────────────────────
  backends = {
    psc = {
      protocol     = "HTTP"
      port         = 80
      security_policy = google_compute_security_policy.waf.id

      groups = [{
        group                 = google_compute_region_network_endpoint_group.psc_neg.id
        balancing_mode        = "RATE"
        max_rate_per_endpoint = 150
      }]

      health_check = {            # inline HC object per module schema
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
  name                  = "edge-psc-neg"
  region                = var.region
  project               = module.project_a.project_id

  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = google_compute_service_attachment.svc_attach.self_link
  network   = module.vpc_ext.network_self_link
  subnetwork = module.vpc_ext.subnets["${var.region}/psc-endpoints"].self_link
}