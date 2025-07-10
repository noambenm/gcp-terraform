module "gke" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                 = "~> 37.0"
  project_id              = module.project_b.project_id
  name                    = "gke-cluster"
  region                  = "us-central1"
  zones                   = ["us-central1-a"]
  network                 = module.vpc_int.network_name
  subnetwork              = module.vpc_int.subnets["${var.region}/gke-nodes"].name
  ip_range_pods           = module.vpc_int.subnets["${var.region}/gke-nodes"].secondary_ip_range[0].range_name
  ip_range_services       = module.vpc_int.subnets["${var.region}/gke-nodes"].secondary_ip_range[1].range_name
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block

  master_authorized_networks = [
    {
      cidr_block   = var.vpc_a_cidr
      display_name = "Allow Project A VPC"
    }
  ]

  node_pools = [
    {
      name            = "primary-node-pool"
      machine_type    = var.machine_type
      min_count       = var.min_node_count
      max_count       = var.max_node_count
      disk_size_gb    = 100
      disk_type       = "pd-standard"
      auto_repair     = true
      auto_upgrade    = true
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  ]

  node_pools_oauth_scopes = {
    all = []
    primary-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}
    primary-node-pool = {
      environment = "production"
      cluster     = "primary"
    }
  }

  node_pools_metadata = {
    all = {}
    primary-node-pool = {
      node-pool-metadata-custom-value = "primary-node-pool"
    }
  }

  node_pools_taints = {
    all               = []
    primary-node-pool = []
  }

  node_pools_tags = {
    all               = []
    primary-node-pool = ["gke-node", "primary-node-pool"]
  }

  # Security features
  enable_shielded_nodes       = true
  enable_binary_authorization = true

  # Workload Identity
  identity_namespace = "${module.project_b.project_id}.svc.id.goog"

  # VPA configuration
  enable_vertical_pod_autoscaling = true
} 