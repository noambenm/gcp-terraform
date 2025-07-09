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

