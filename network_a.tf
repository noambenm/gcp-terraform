resource "google_compute_network" "vpc_ext" {
  name                    = "vpc-ext"
  auto_create_subnetworks = false
  project                 = google_project.project_a.project_id
}

resource "google_compute_subnetwork" "proxy_only" {
  name          = "lb-proxy-only-${var.region}"
  network       = google_compute_network.vpc_ext.id
  region        = var.region
  ip_cidr_range = var.proxy_only_cidr
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "psc_endpoints" {
  name          = "psc-endpoints"
  region        = var.region
  network       = google_compute_network.vpc_ext.id
  ip_cidr_range = var.psc_consumer_cidr
  purpose       = "PRIVATE_SERVICE_CONNECT"
  role          = "ACTIVE"
  project       = google_project.project_a.project_id
}

resource "google_compute_global_address" "psc_consumer_ip" {
  name         = "psc-endpoint-ip"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  address_type = "INTERNAL"
  address      = var.psc_endpoint_ip
  network      = google_compute_network.vpc_ext.id
}

resource "google_compute_firewall" "allow_lb_to_psc" {
  name          = "fw-allow-lb-to-psc"
  network       = google_compute_network.vpc_ext.id
  direction     = "INGRESS"
  priority      = 1000

  source_ranges      = [google_compute_subnetwork.proxy_only.ip_cidr_range]
  destination_ranges = [google_compute_subnetwork.psc_consumer.ip_cidr_range]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]   # adjust if your backend listens elsewhere
  }
}