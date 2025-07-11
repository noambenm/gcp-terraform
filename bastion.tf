resource "google_service_account" "bastion_sa" {
  account_id   = "bastion-sa"
  display_name = "Bastion host SA"
  project      = module.project_b.project_id
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  project      = module.project_b.project_id
  zone         = "${var.region}-a"
  machine_type = "e2-micro"

  tags = ["iap-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-balanced"
      size  = 10
    }
  }

  network_interface {
    network    = module.vpc_int.network_name
    subnetwork = module.vpc_int.subnets["${var.region}/${var.gke_nodes_range_name}"].self_link
  }

  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  depends_on = [module.vpc_int]
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-ssh-iap"
  project = module.project_b.project_id
  network = module.vpc_int.network_name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]

  description = "Allow SSH from Cloud IAP to bastion host"

  depends_on = [module.vpc_int]
}
