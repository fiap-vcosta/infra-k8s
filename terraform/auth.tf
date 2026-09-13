locals {
  auth_image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository}/auth:latest"
}

resource "google_cloud_run_v2_service" "auth" {
  name     = var.auth_service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = var.auth_max_instance_count
    }

    timeout = var.auth_timeout

    containers {
      image = local.auth_image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = var.auth_cpu
          memory = var.auth_memory
        }
      }

      env {
        name  = "API_BASE_URL"
        value = var.auth_api_base_url
      }

      env {
        name  = "JWT_CLIENTE_KEY"
        value = var.auth_jwt_cliente_key
      }

      env {
        name  = "JWT_CLIENTE_ISSUER"
        value = var.auth_jwt_cliente_issuer
      }

      env {
        name  = "JWT_CLIENTE_AUDIENCE"
        value = var.auth_jwt_cliente_audience
      }

      env {
        name  = "SERVICE_AUTH_KEY"
        value = var.auth_service_auth_key
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "auth_public_invoker" {
  project  = google_cloud_run_v2_service.auth.project
  location = google_cloud_run_v2_service.auth.location
  name     = google_cloud_run_v2_service.auth.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
