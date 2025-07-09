terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.42.0"
    }
  }
  backend "gcs" {
    bucket = "tfstate-mgmt-465320"
    prefix = "prod"
  }
}

provider "google" {
}