resource "google_compute_router" "nat" {
  name    = "${var.cluster_name}-nat-router"
  project = var.project_id
  region  = var.region
  network = data.terraform_remote_state.bootstrap.outputs.network_id
}

resource "google_compute_router_nat" "main" {
  name                               = "${var.cluster_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.nat.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = data.terraform_remote_state.bootstrap.outputs.subnet_id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}
