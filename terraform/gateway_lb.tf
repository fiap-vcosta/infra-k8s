locals {
  gateway_entry_hostname = local.dns_name
}

resource "google_compute_global_address" "gateway_entry" {
  name         = var.gateway_entry_ip_name
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_region_network_endpoint_group" "gateway" {
  provider              = google-beta
  name                  = "${var.gateway_id}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_gateway.main.gateway_id
  }
}

resource "google_compute_backend_service" "gateway" {
  provider              = google-beta
  name                  = "${var.gateway_id}-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"

  backend {
    group = google_compute_region_network_endpoint_group.gateway.id
  }
}

resource "google_compute_url_map" "gateway" {
  provider        = google-beta
  name            = "${var.gateway_id}-url-map"
  default_service = google_compute_backend_service.gateway.id
}

resource "google_compute_managed_ssl_certificate" "gateway_entry" {
  name = "${var.gateway_id}-entry-cert"

  managed {
    domains = [local.gateway_entry_hostname]
  }
}

resource "google_compute_target_https_proxy" "gateway" {
  provider         = google-beta
  name             = "${var.gateway_id}-https-proxy"
  url_map          = google_compute_url_map.gateway.id
  ssl_certificates = [google_compute_managed_ssl_certificate.gateway_entry.id]
}

resource "google_compute_global_forwarding_rule" "gateway_https" {
  provider              = google-beta
  name                  = "${var.gateway_id}-https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.gateway.id
  ip_address            = google_compute_global_address.gateway_entry.id
}

resource "google_compute_url_map" "gateway_http_redirect" {
  provider = google-beta
  name     = "${var.gateway_id}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "gateway_http_redirect" {
  provider = google-beta
  name     = "${var.gateway_id}-http-proxy"
  url_map  = google_compute_url_map.gateway_http_redirect.id
}

resource "google_compute_global_forwarding_rule" "gateway_http" {
  provider              = google-beta
  name                  = "${var.gateway_id}-http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.gateway_http_redirect.id
  ip_address            = google_compute_global_address.gateway_entry.id
}
