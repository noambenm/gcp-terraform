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