locals {
  dns_zone_name = data.terraform_remote_state.bootstrap.outputs.dns_managed_zone_name
  dns_name      = trimsuffix(data.terraform_remote_state.bootstrap.outputs.dns_name, ".")
  api_hostname  = "api.${local.dns_name}"
  auth_hostname = "auth.${local.dns_name}"
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

resource "google_cloud_run_domain_mapping" "auth" {
  location = var.region
  name     = local.auth_hostname

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.auth.name
  }
}

resource "google_dns_record_set" "auth" {
  name         = "${local.auth_hostname}."
  managed_zone = local.dns_zone_name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["ghs.googlehosted.com."]
}
