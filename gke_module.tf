locals {
  roles = [
    "roles/container.defaultNodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
  ]
}

resource "google_service_account" "gke_nodes" {
  project      = module.project_b.project_id
  account_id   = "gke-node-sa"
  display_name = "GKE node pool service account"
}

resource "google_project_iam_member" "gke_nodes_role" {
  for_each = toset(local.roles)
  project = module.project_b.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 37"

  depends_on = [
    module.project_b,
    google_project_iam_member.project_module_owner_sa["project_b"],
    module.vpc_int,
    google_project_iam_member.gke_nodes_role
  ]

  project_id = module.project_b.project_id
  name       = "gke-cluster"
  region     = var.region
  zones      = ["${var.region}-a"]
  regional   = false
  deletion_protection = false

  network           = module.vpc_int.network_name
  subnetwork        = var.gke_nodes_range_name
  ip_range_pods     = var.gke_pods_range_name
  ip_range_services = var.gke_services_range_name
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  service_account = google_service_account.gke_nodes.email

  master_authorized_networks = [
    {
      cidr_block   = var.gke_nodes_cidr
      display_name = "Allow Project B VPC"
    },
    {
      cidr_block  = var.home_ip
      display_name = "Allow home IP"
    }
  ]

  release_channel = "REGULAR"

  remove_default_node_pool = true
  initial_node_count       = 1

  node_pools = [
    {
      name                      = "primary-node-pool"
      machine_type              = var.machine_type
      min_count                 = var.min_node_count
      max_count                 = var.max_node_count
      local_ssd_count          = 0
      spot                     = false
      disk_size_gb             = 100
      disk_type                = "pd-standard"
      image_type               = "COS_CONTAINERD"
      enable_gcfs              = false
      enable_gvnic             = false
      auto_repair              = true
      auto_upgrade             = true
      preemptible              = false
      initial_node_count       = 1
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    primary-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_pools_labels = {
    primary-node-pool = {
      environment = "production"
      cluster     = "primary"
    }
  }

  node_pools_metadata = {
    primary-node-pool = {
      node-pool-metadata-custom-value = "primary-node-pool"
    }
  }

  node_pools_taints = {
    primary-node-pool = []
  }

  node_pools_tags = {
    primary-node-pool = ["gke-node", "primary-node-pool"]
  }

  enable_shielded_nodes       = true
  enable_binary_authorization = true
  identity_namespace         = "enabled"
  enable_vertical_pod_autoscaling = true
}