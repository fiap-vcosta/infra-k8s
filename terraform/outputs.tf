output "cluster_name" {
  description = "Nome do cluster, usado pelo deploy da api."
  value       = google_container_cluster.main.name
}

output "cluster_location" {
  description = "Região do cluster regional."
  value       = google_container_cluster.main.location
}
