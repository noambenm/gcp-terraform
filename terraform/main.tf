terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.42.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.7.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
  backend "gcs" {
    bucket = "tfstate-mgmt-465320"
    prefix = "prod"
  }
}