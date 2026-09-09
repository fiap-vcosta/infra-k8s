resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = false

  network    = data.terraform_remote_state.bootstrap.outputs.network_id
  subnetwork = data.terraform_remote_state.bootstrap.outputs.subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = data.terraform_remote_state.bootstrap.outputs.pods_range_name
    services_secondary_range_name = data.terraform_remote_state.bootstrap.outputs.services_range_name
  }

  release_channel {
    channel = var.release_channel
  }

  private_cluster_config {
    enable_private_nodes = true
  }

  control_plane_endpoints_config {
    dns_endpoint_config {
      allow_external_traffic = true
    }

    ip_endpoints_config {
      enabled = false
    }
  }
}
