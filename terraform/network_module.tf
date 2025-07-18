module "vpc_ext" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.0"

  project_id   = module.project_a.project_id
  network_name = "vpc-ext"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "lb-proxy-only-${var.region}"
      subnet_ip             = var.proxy_only_cidr
      subnet_region         = var.region
      subnet_private_access = false
      purpose               = "INTERNAL_HTTPS_LOAD_BALANCER"
      role                  = "ACTIVE"
    },
    {
      subnet_name           = "psc-endpoints"
      subnet_ip             = var.psc_consumer_cidr
      subnet_region         = var.region
      subnet_private_access = false
      purpose               = "PRIVATE_SERVICE_CONNECT"
      role                  = "ACTIVE"
    }
  ]

  firewall_rules = [{
    name                    = "fw-allow-lb-to-psc"
    description             = "Allow traffic from Load Balancer to PSC endpoints"
    direction               = "INGRESS"
    priority                = 1000
    ranges                  = [var.proxy_only_cidr]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["80", "443"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}

module "vpc_int" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.0"

  project_id   = module.project_b.project_id
  network_name = "vpc-int"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = var.gke_nodes_range_name
      subnet_ip             = var.gke_nodes_cidr
      subnet_region         = var.region
      subnet_private_access = true
    },
    {
      subnet_name           = "psc-nat"
      subnet_ip             = var.psc_nat_cidr
      subnet_region         = var.region
      subnet_private_access = false
      purpose               = "PRIVATE_SERVICE_CONNECT"
      role                  = "ACTIVE"
    }
  ]
  secondary_ranges = {
    "${var.gke_nodes_range_name}" = [
      {
        range_name    = var.gke_pods_range_name
        ip_cidr_range = var.gke_pods_cidr
      },
      {
        range_name    = var.gke_services_range_name
        ip_cidr_range = var.gke_services_cidr
      }      
    ]
  }
} 

module "cloud-router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 7.1"
  
  name = "nat-router"
  network = module.vpc_int.network_name
  project = module.project_b.project_id
  region = var.region
    nats = [{
    name                               = "nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  }]
}
