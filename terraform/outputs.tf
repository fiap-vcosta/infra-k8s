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

output "api_static_ip" {
  description = "IP global para o Ingress da API (annotation kubernetes.io/ingress.global-static-ip-name)."
  value       = google_compute_global_address.api.address
}

output "api_static_ip_name" {
  description = "Nome do recurso do IP global da API."
  value       = google_compute_global_address.api.name
}

output "api_hostname" {
  description = "Hostname DNS da API (A → api_static_ip)."
  value       = local.api_hostname
}

output "auth_hostname" {
  description = "Hostname DNS do auth (CNAME → ghs.googlehosted.com)."
  value       = local.auth_hostname
}
