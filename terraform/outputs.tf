output "cluster_name" {
  description = "Nome do cluster, usado pelo deploy dos serviços."
  value       = google_container_cluster.main.name
}

output "cluster_location" {
  description = "Região do cluster regional."
  value       = google_container_cluster.main.location
}

output "k8s_namespace" {
  description = "Namespace do Gateway e das service accounts Kubernetes."
  value       = var.k8s_namespace
}

output "gke_gateway_name" {
  description = "Nome do Gateway do GKE. HTTPRoute de serviço referencia este nome no listener https."
  value       = var.gke_gateway_name
}

output "api_static_ip" {
  description = "IP global do Gateway do GKE (A de api.<domínio>)."
  value       = google_compute_global_address.api.address
}

output "api_static_ip_name" {
  description = "Nome do IP global do Gateway do GKE."
  value       = google_compute_global_address.api.name
}

output "api_ssl_certificate_name" {
  description = "Certificado gerenciado anexado ao listener HTTPS do Gateway do GKE."
  value       = google_compute_managed_ssl_certificate.api.name
}

output "api_hostname" {
  description = "Hostname do backend (A → api_static_ip). O API Gateway chama https:// neste nome."
  value       = local.api_hostname
}

output "gateway_entry_ip" {
  description = "IP global do HTTPS LB da entrada (A do apex no Cloud DNS)."
  value       = google_compute_global_address.gateway_entry.address
}

output "gateway_entry_ip_name" {
  description = "Nome do recurso do IP de entrada."
  value       = google_compute_global_address.gateway_entry.name
}

output "gateway_entry_hostname" {
  description = "Hostname publico da entrada (apex do dominio)."
  value       = local.gateway_entry_hostname
}
