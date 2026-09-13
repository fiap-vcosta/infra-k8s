output "cluster_name" {
  description = "Nome do cluster, usado pelo deploy da api."
  value       = google_container_cluster.main.name
}

output "cluster_location" {
  description = "Região do cluster regional."
  value       = google_container_cluster.main.location
}

output "auth_service_uri" {
  description = "URL HTTPS pública do Cloud Run auth."
  value       = google_cloud_run_v2_service.auth.uri
}

output "auth_image" {
  description = "Imagem aplicada no Cloud Run auth."
  value       = local.auth_image
}
