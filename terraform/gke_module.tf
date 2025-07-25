module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 37.0"

  depends_on = [
    module.project_b,
    module.vpc_int,
  ]

  project_id = module.project_b.project_id
  name       = "gke-cluster"
  region     = var.region
  zones      = ["${var.region}-a"]
  regional   = false
  deletion_protection = false

  network           = module.vpc_int.network_name
  subnetwork        = module.vpc_int.subnets_names[0]
  ip_range_pods     = module.vpc_int.subnets_secondary_ranges[0][0].range_name
  ip_range_services = module.vpc_int.subnets_secondary_ranges[0][1].range_name
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  
  release_channel = "REGULAR"

  remove_default_node_pool = true
  initial_node_count       = 1

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "Allow from anywhere"
    }
  ]

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