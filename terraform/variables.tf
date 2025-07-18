variable "region" {
  description = "The region where the resources will be created."
  type        = string
  default     = "us-central1"
}

variable "billing_account_id" {
  description = "Billing account ID in the form ######-######-######."
  type        = string
  sensitive = true
}

variable "org_id" {
  description = "Numeric ID of the GCP organisation that will own the projects."
  type        = string
  sensitive = true
}

variable "terraform_sa_email" {
  description = "Email of the central Terraform service account to be granted Owner on both projects."
  type        = string
  sensitive = true
}

variable "proxy_only_cidr" {
  description = "/24 CIDR for the proxy-only subnet in VPC A"
  type        = string
  default     = "10.1.0.0/24"
}

variable "psc_consumer_cidr" {
  description = "CIDR for the PSC consumer subnet in VPC A"
  type        = string
  default     = "10.1.1.0/28"
}

variable "gke_nodes_range_name" {
  description = "Name of the secondary subnet range used for GKE Nodes"
  type        = string
  default     = "gke-nodes"
}

variable "gke_pods_range_name" {
  description = "Name of the secondary subnet range used for GKE Pods"
  type        = string
  default     = "gke-pods"

}
variable "gke_nodes_cidr" {
  description = "CIDR range for the GKE nodes subnet in VPC B"
  type        = string
  default     = "10.2.0.0/20"
}

variable "gke_services_range_name" {
  description = "Name of the secondary subnet range used for GKE Services"
  type        = string
  default     = "gke-services"
}

variable "gke_pods_cidr" {
  description = "Secondary IP range for GKE pods"
  type        = string
  default     = "10.20.0.0/16"
}

variable "gke_services_cidr" {
  description = "Secondary IP range for GKE services"
  type        = string
  default     = "10.30.0.0/20"
}

variable "psc_nat_cidr" {
  description = "CIDR for PSC NAT subnet in Project B"
  type        = string
  default     = "10.2.16.0/29"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the GKE master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "min_node_count" {
  description = "Minimum number of nodes in the GKE node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the GKE node pool"
  type        = number
  default     = 5
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "fluxcd_github_pat" {
  description = "GitHub token for Flux authentication"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare mdch-lab zone ID"
  type        = string
  default     = "5f738d8a328d15cbfba51970464fd84e"
}