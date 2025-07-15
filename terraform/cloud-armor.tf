resource "google_compute_security_policy" "waf" {
  name        = "edge-waf"
  description = "Allow Israel, block everything else"
  project     = module.project_a.project_id

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = true
      rule_visibility = "STANDARD"
    }
  }

  rule {
    priority = 1000
    action   = "allow"

    match {
      expr {
        expression = "origin.region_code == 'IL'"
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