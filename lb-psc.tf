resource "google_compute_ssl_policy" "modern_tls" {
  name            = "edge-modern-tls"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

module "edge_lb" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 12.2"
  name    = "edge-lb"
  project = module.project_a.project_id
  network = module.vpc_ext.network_self_link

  ssl                     = true
  managed_ssl_certificate_domains = ["dashy-gcp.mdch-lab.dev"]
  https_redirect          = true
  quic                    = true
  ssl_policy              = google_compute_ssl_policy.modern_tls.self_link

  backends = {
    default = {
      description = "PSC NEG backend"
      groups = [
        {
          group = google_compute_region_network_endpoint_group.psc_neg.id
        }
      ]
      security_policy = google_compute_security_policy.waf.id

      log_config = { enable = true, sample_rate = 1.0 }
    }
  }
}


resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "psc-neg"
  region                = var.region
  project               = module.project_a.project_id
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = "https://www.googleapis.com/compute/v1/projects/project-b-4d5b/regions/us-central1/serviceAttachments/k8s1-sa-ll5ci21v-ingress-nginx-nginx-ingress-sa-l67qv7nn"
  network               = module.vpc_ext.network_self_link
  subnetwork            = module.vpc_ext.subnets_self_links[1]
}

# data "external" "ingress_sa_url" {
#   depends_on = [ flux_bootstrap_git.flux_bootstrap ]
#   program = ["bash", "-c", <<EOT
# echo "{\"url\": \"$(kubectl get serviceattachment nginx-ingress-sa -n ingress-nginx -o jsonpath='{.status.serviceAttachmentURL}')\"}"
# EOT
#   ]
# }
