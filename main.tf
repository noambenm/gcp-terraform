terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.42.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.6.4"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
  backend "gcs" {
    bucket = "tfstate-mgmt-465320"
    prefix = "prod"
  }
}