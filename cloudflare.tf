
data "cloudflare_zone" "mdch_lab" {
  name = "mdch-lab.dev"
}

resource "cloudflare_record" "dashy_a" {
  zone_id = data.cloudflare_zone.mdch_lab.id
  name    = "dashy-gcp.mdch-lab.dev"
  type    = "A"
  value   = module.edge_lb.external_ip
  ttl     = 300
  proxied = true
}