resource "cloudflare_dns_record" "dashy_a" {
  zone_id = var.zone_id
  name    = "dashy-gcp"
  type    = "A"
  content = module.edge_lb.external_ip
  ttl     = 60
  proxied = false
}