resource "google_compute_network" "vpc_int" {
  name                    = "vpc-int"
  auto_create_subnetworks = false
  project                 = google_project.project_b.project_id
}

resource "google_compute_subnetwork" "psc_nat" {
  name          = "psc-nat-${var.region}"
  project       = google_project.project_b.project_id
  region        = var.region
  network       = google_compute_network.vpc_int.id
  ip_cidr_range = var.psc_nat_cidr
  purpose       = "PRIVATE_SERVICE_CONNECT"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "gke_nodes" {
  name          = "gke-nodes"
  region        = var.region
  network       = google_compute_network.vpc_int.self_link
  ip_cidr_range = var.gke_nodes_cidr
  project       = google_project.project_b.project_id

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = var.gke_pod_cidr
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = var.gke_service_cidr
  }

  private_ip_google_access = true
}

resource "google_compute_router" "int_router" {
  name    = "router-int"
  region  = var.region
  network = google_compute_network.vpc_int.self_link
  project = google_project.project_b.project_id
}

resource "google_compute_router_nat" "int_nat" {
  name                               = "int-nat"
  router                             = google_compute_router.int_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = google_project.project_b.project_id
}

# Allow nodes to communicate with each other and pods
resource "google_compute_firewall" "allow_internal" {
  name        = "allow-internal-cluster"
  network     = google_compute_network.vpc_int.self_link
  project     = google_project.project_b.project_id
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [
    var.gke_nodes_cidr,   # Node CIDR
    var.gke_pod_cidr,     # Pod CIDR
    var.gke_service_cidr  # Service CIDR
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  # Don't specify target tags - let GKE manage them
}

resource "google_compute_firewall" "allow_health_checks" {
  name          = "fw-allow-health-checks"
  network       = google_compute_network.vpc_int.self_link
  direction     = "INGRESS"
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
    "35.235.240.0/20"
  ]
  project       = google_project.project_b.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  allow {
    protocol = "udp"
  }
  description = "Allow Google health-check probes"
}

resource "google_compute_firewall" "allow_psc_from_a" {
  name          = "fw-allow-psc-from-a"
  network       = google_compute_network.vpc_int.self_link
  direction     = "INGRESS"
  source_ranges = [var.psc_consumer_cidr]
  project       = google_project.project_b.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  description = "Allow PSC endpoint traffic from Project A"
}
