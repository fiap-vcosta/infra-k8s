locals {
  gateway_auth_backend_url = coalesce(var.gateway_auth_backend_url, "https://${local.auth_hostname}")
  gateway_api_backend_url  = coalesce(var.gateway_api_backend_url, "https://${local.api_hostname}")
  gateway_openapi = templatefile("${path.module}/openapi/gateway.yaml.tftpl", {
    auth_backend_url = local.gateway_auth_backend_url
    api_backend_url  = local.gateway_api_backend_url
    entry_hostname   = local.dns_name
  })
  gateway_openapi_hash = substr(sha256(local.gateway_openapi), 0, 8)
}

resource "google_api_gateway_api" "main" {
  provider = google-beta
  api_id   = var.gateway_api_id
}

resource "google_api_gateway_api_config" "main" {
  provider      = google-beta
  api           = google_api_gateway_api.main.api_id
  api_config_id = "${var.gateway_api_id}-${local.gateway_openapi_hash}"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = base64encode(local.gateway_openapi)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "main" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.main.id
  gateway_id = var.gateway_id
  region     = var.region

  depends_on = [google_api_gateway_api_config.main]
}
