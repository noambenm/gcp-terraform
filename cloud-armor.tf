resource "google_compute_security_policy" "waf" {
  name        = "edge-waf"
  description = "Allow Cloudflare IPs, block everything else"
  project     = module.project_a.project_id

  rule {
    priority = 1000
    action   = "allow"

    match {
      expr {
        expression = "source.region_code == 'IL'"
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