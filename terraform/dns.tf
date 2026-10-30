locals {
  dns_zone_name = data.terraform_remote_state.bootstrap.outputs.dns_managed_zone_name
  dns_name      = trimsuffix(data.terraform_remote_state.bootstrap.outputs.dns_name, ".")
  api_hostname  = "api.${local.dns_name}"
}

resource "google_compute_global_address" "api" {
  name         = var.api_static_ip_name
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_dns_record_set" "api" {
  name         = "${local.api_hostname}."
  managed_zone = local.dns_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.api.address]
}

resource "google_compute_managed_ssl_certificate" "api" {
  name = var.api_ssl_certificate_name

  managed {
    domains = [local.api_hostname]
  }
}

resource "google_dns_record_set" "apex" {
  name         = "${local.dns_name}."
  managed_zone = local.dns_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gateway_entry.address]
}
