locals {
  # Cloudflare IPv4 / IPv6 ranges – update periodically
  cf_ipv4 = [
    "173.245.48.0/20", "103.21.244.0/22", "104.16.0.0/13",
    "131.0.72.0/22", "190.93.240.0/20", "108.162.192.0/18"
  ]

  cf_ipv6 = [
    "2400:cb00::/32", "2606:4700::/32", "2803:f800::/32"
  ]

  allowed_ips = concat(local.cf_ipv4, local.cf_ipv6, [var.home_ip],)
}

resource "google_compute_security_policy" "waf" {
  name        = "edge-waf"
  description = "Allow Cloudflare IPs, block everything else"
  project     = module.project_a.project_id

  rule {
    priority = 1000
    action   = "allow"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = local.allowed_ips
      }
    }
  }

  rule {
    priority = 2147483647 # catch‑all
    action   = "deny(403)"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}