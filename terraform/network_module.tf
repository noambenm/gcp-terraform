module "vpc_ext" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.0"

  project_id   = module.project_a.project_id
  network_name = "vpc-ext"
  routing_mode = "GLOBAL" # tells Google Cloud how far the dynamic BGP routes that Cloud Routers learn or advertise should spread inside that VPC, can be "GLOBAL" or "REGIONAL"

  subnets = [
    {
      subnet_name           = "lb-proxy-only-${var.region}"
      subnet_ip             = var.proxy_only_cidr
      subnet_region         = var.region
      subnet_private_access = false # turn on Private Google Access which allows VMs in this subnet to access Google APIs and services without an external IP address
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
  version = "~> 7.0"
  
  name = "nat-router"
  network = module.vpc_int.network_name
  project = module.project_b.project_id
  region = var.region
    nats = [{
    name                               = "nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  }]
}
