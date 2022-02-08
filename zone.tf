locals {
  primary_domain  = "lauxanh.us"
  spf_default     = "include:_spf.mx.cloudflare.net include:zoho.com include:_spf.google.com ~all"
  zoho_domain_key = "INPUT_YOUR_ZOHO_DKIM_KEY_HERE"
}

data "cloudflare_zone" "lauxanh" {
  name = local.primary_domain
}

resource "cloudflare_record" "star" {
  zone_id = data.cloudflare_zone.lauxanh.id
  name    = "*"
  value   = "127.0.2.1"
  type    = "A"
  ttl     = 60
  proxied = false
}

locals {
  # HELP: https://faq.tuxfamily.org/WebArea/En
  cnames = {
    download   = ["web.tuxfamily.net", true],
    "@"        = ["web.tuxfamily.net", true],
    www        = [local.primary_domain, true],
    zb32334146 = ["zmverify.zoho.com", false],
  }

  mx = {
    10  = "isaac.mx.cloudflare.net"
    20  = "linda.mx.cloudflare.net"
    30  = "amir.mx.cloudflare.net"
    100 = "mx.zoho.com"
    120 = "mx2.zoho.com"
    130 = "mx3.zoho.com"
    # 40 = "alt1.aspmx.l.google.com"
    # 45 = "alt2.aspmx.l.google.com"
    # 50 = "aspmx.l.google.com"
    # 55 = "aspmx2.googlemail.com"
    # 60 = "aspmx3.googlemail.com"
  }

  legacy_sites = [
    "2005",
    "2008",
    "blog",
    "ctan",
    "dragula",
    "insecure",
    "sarovar",
    "wiki",
    "winefish",
    "zine",
  ]

  legacy_sites_as_map = { for item in local.legacy_sites : item => item }
}

resource "cloudflare_record" "mx" {
  for_each = local.mx
  zone_id  = data.cloudflare_zone.lauxanh.id
  name     = local.primary_domain
  ttl      = 60
  type     = "MX"
  value    = each.value
  proxied  = false
  priority = each.key
}

resource "cloudflare_record" "cnames" {
  for_each = local.cnames
  zone_id  = data.cloudflare_zone.lauxanh.id
  name     = each.key
  value    = each.value[0]
  type     = "CNAME"
  ttl      = each.value[1] ? 1 : 60
  proxied  = each.value[1]
}

resource "cloudflare_record" "legacy" {
  for_each = local.legacy_sites_as_map
  zone_id  = data.cloudflare_zone.lauxanh.id
  name     = each.key
  value    = local.primary_domain
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

# DOC: https://support.google.com/a/answer/10684623?hl=en
# DOC: `dig txt +short lauxanh.org`
resource "cloudflare_record" "spf" {
  zone_id = data.cloudflare_zone.lauxanh.id
  name    = "@"
  value   = "v=spf1 ${local.spf_default}"
  type    = "TXT"
  ttl     = 60
  proxied = false
}

resource "cloudflare_record" "zoho_dkim" {
  zone_id = data.cloudflare_zone.lauxanh.id
  name    = "zmail._domainkey"
  value   = local.zoho_domain_key
  type    = "TXT"
  ttl     = 60
  proxied = false
}
