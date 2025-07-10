variable "mgmt_project_id" {
  description = "The ID of the project where the resources will be created."
  type        = string
  default = "mgmt-465320"
}
variable "region" {
  description = "The region where the resources will be created."
  type        = string
  default     = "us-central1"
}

variable "project_a_id" {
  description = "ID for Project A (must be globally unique, e.g. 'edge-prod-1234')."
  type        = string
  default     = "project-a-external"
}

variable "project_b_id" {
  description = "ID for Project B (must be globally unique, e.g. 'workload-prod-1234')."
  type        = string
  default     = "project-b-internal"
}

variable "billing_account_id" {
  description = "Billing account ID in the form ######-######-######."
  type        = string
}

variable "org_id" {
  description = "Numeric ID of the GCP organisation that will own the projects."
  type        = string
}

variable "terraform_sa_email" {
  description = "Email of the central Terraform service account to be granted Owner on both projects."
  type        = string
}

variable "vpc_a_cidr" {
  description = "CIDR for VPC A (external)"
  type        = string
  default     = "10.0.0.0/20"  # Smaller CIDR for external VPC
}

variable "proxy_only_cidr" {
  description = "/24 CIDR for the proxy-only subnet in VPC A"
  type        = string
  default     = "10.1.0.0/24"  # Separate range for proxy-only subnet
}

variable "psc_consumer_cidr" {
  description = "/24 CIDR for the PSC consumer subnet in VPC A"
  type        = string
  default     = "10.1.1.0/24"  # Larger range for PSC endpoints
}

variable "gke_nodes_cidr" {
  description = "CIDR range for the GKE nodes subnet in VPC B"
  type        = string
  default     = "10.2.16.0/20"  # Dedicated range for GKE nodes
}

variable "gke_pod_cidr" {
  description = "Secondary IP range for GKE pods"
  type        = string
  default     = "10.20.0.0/16"  # Large range for pods (65,536 IPs)
}

variable "gke_service_cidr" {
  description = "Secondary IP range for GKE services"
  type        = string
  default     = "10.30.0.0/20"  # Range for services (4,096 IPs)
}

variable "psc_nat_cidr" {
  description = "CIDR for PSC NAT subnet in Project B"
  type        = string
  default     = "10.2.32.0/24"  # Dedicated range for PSC NAT
}

variable "psc_endpoint_ip" {
  description = "Single IP inside psc_consumer_cidr for the PSC endpoint"
  type        = string
  default     = "10.0.1.10"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the GKE master network"
  type        = string
  default     = "172.16.0.0/28"  # /28 provides 16 IP addresses
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
  default     = "e2-standard-4"  # 4 vCPU, 16GB memory
}