resource "google_project" "project_a" {
  project_id      = var.project_a_id
  name            = "project-a"
  billing_account = var.billing_account_id
  org_id          = var.org_id

  labels = {
    environment = "prod"
    tier        = "edge"
  }
}

resource "google_project" "project_b" {
  project_id      = var.project_b_id
  name            = "project-b"
  billing_account = var.billing_account_id
  org_id          = var.org_id

  labels = {
    environment = "prod"
    tier        = "workload"
  }
}

resource "google_project_iam_member" "project_owner_sa" {
  for_each = {
    project_a = google_project.project_a.project_id
    project_b = google_project.project_b.project_id
  }

  project = each.value
  role    = "roles/owner"
  member  = "serviceAccount:${var.terraform_sa_email}"
}
