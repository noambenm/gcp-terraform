provider "google" {
}

provider "flux" {
  kubernetes = {
    host                   = module.gke.endpoint
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
  git = {
    url = "https://github.com/noambenm/gcp-terraform.git"
    http = {
      username = "git"
      password = var.fluxcd_github_pat
    }
  }
} 