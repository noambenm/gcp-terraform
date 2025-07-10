resource "google_container_cluster" "gke_cluster" {
  name               = "gke-cluster"
  location           = "us-central1-a"
  project            = google_project.project_b.project_id
  deletion_protection = false

  # Networking
  network    = google_compute_network.vpc_int.self_link
  subnetwork = google_compute_subnetwork.gke_nodes.self_link
  networking_mode = "VPC_NATIVE"

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }

  # Master authorized networks - adjust as needed
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.vpc_a_cidr
      display_name = "Allow Project A VPC"
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${google_project.project_b.project_id}.svc.id.goog"
  }

  # Configure IP allocation policy for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke_nodes.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke_nodes.secondary_ip_range[1].range_name
  }

  # Remove default node pool and manage it separately
  remove_default_node_pool = true
  initial_node_count       = 1

  # Release channel for auto-updates
  release_channel {
    channel = "REGULAR"
  }

  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T00:00:00Z"
      end_time   = "2024-01-01T04:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"  # Weekends
    }
  }

  # Enable VPA
  vertical_pod_autoscaling {
    enabled = true
  }

  # Binary Authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
}

# Create a separately managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  project    = google_project.project_b.project_id
  location   = "us-central1-a"  # Match cluster's zone
  cluster    = google_container_cluster.gke_cluster.name

  # Autoscaling configuration
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Node configuration
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 100
    disk_type    = "pd-standard"

    # Google recommended node labels
    labels = {
      environment = "production"
      cluster     = "primary"
    }

    # OAuth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable workload identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Ensure nodes have minimal needed permissions
    service_account = google_service_account.gke_nodes.email

    # Enable secure boot for nodes
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Update strategy
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# Create dedicated service account for nodes
resource "google_service_account" "gke_nodes" {
  project      = google_project.project_b.project_id
  account_id   = "gke-nodes"
  display_name = "GKE Nodes Service Account"
}

# Grant minimal permissions to the node service account
resource "google_project_iam_member" "node_sa_permissions" {
  for_each = toset([
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/logging.logWriter",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer"  # For pulling container images
  ])

  project = google_project.project_b.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}