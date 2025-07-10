locals {
  enabled_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "networkconnectivity.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "artifactregistry.googleapis.com",
    "containerregistry.googleapis.com",
    "dns.googleapis.com"
  ]
  environment   = "prod"
  org_prefix    = "mdch-lab.dev"
}

module "project_a" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"
  name            = "project-a"
  org_id          = var.org_id
  billing_account = var.billing_account_id
  activate_apis = local.enabled_apis
  deletion_policy = "DELETE"
  labels = {
    environment = local.environment
    tier        = "edge"
    managed-by  = "terraform"
  }

  auto_create_network = false
  random_project_id  = true
}

module "project_b" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"
  name            = "project-b"
  org_id          = var.org_id
  billing_account = var.billing_account_id
  activate_apis = local.enabled_apis
  deletion_policy = "DELETE"
  labels = {
    environment = local.environment
    tier        = "workload"
    managed-by  = "terraform"
  }

  auto_create_network = false
  random_project_id  = true
}

resource "google_project_iam_member" "project_module_owner_sa" {
  for_each = {
    project_a = module.project_a.project_id
    project_b = module.project_b.project_id
  }

  project = each.value
  role    = "roles/owner"
  member  = "serviceAccount:${var.terraform_sa_email}"
} 