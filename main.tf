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

resource "google_compute_instance" "demo" {
  name         = "tf-demo-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    # uses the default VPC / subnet
    network       = "default"
    access_config {}           # gives the VM an ephemeral public IP
  }

  # quick sanity check when you SSH in
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    echo "Hello from Terraform on $(hostname)" > /var/tmp/terraform.txt
  SCRIPT

  tags = ["terraform-demo"]
}

output "vm_public_ip" {
  description = "SSH here after apply"
  value       = google_compute_instance.demo.network_interface[0].access_config[0].nat_ip
}