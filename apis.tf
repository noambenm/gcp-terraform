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
}

resource "google_project_service" "project_a_services" {
  for_each           = toset(local.enabled_apis)
  project            = google_project.project_a.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_project_service" "project_b_services" {
  for_each           = toset(local.enabled_apis)
  project            = google_project.project_b.project_id
  service            = each.key
  disable_on_destroy = false
}