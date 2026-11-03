variable "project_id" {
  type        = string
  description = "GCP project ID da demo."
  default     = "vcosta-fiap-tech-challenge"
}

variable "region" {
  type        = string
  description = "Região primária da demo (fechada: us-central1)."
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster GKE Autopilot (org var GCP_GKE_CLUSTER_NAME)."
  default     = "tech-challenge-gke"
}

variable "release_channel" {
  type        = string
  description = "Release channel do cluster."
  default     = "REGULAR"
}

variable "k8s_namespace" {
  type        = string
  description = "Namespace compartilhado do Gateway e das service accounts Kubernetes."
  default     = "tech-challenge"
}

variable "gke_gateway_name" {
  type        = string
  description = "Nome do Gateway do GKE no namespace compartilhado."
  default     = "public"
}

variable "api_static_ip_name" {
  type        = string
  description = "Nome do IP global do Gateway do GKE (hostname api.<domínio>)."
  default     = "tech-challenge-api"
}

variable "api_ssl_certificate_name" {
  type        = string
  description = "Nome do certificado gerenciado do hostname api.<domínio>."
  default     = "tech-challenge-api-cert"
}

variable "gateway_api_id" {
  type        = string
  description = "ID do API Gateway API (recurso google_api_gateway_api)."
  default     = "tech-challenge"
}

variable "gateway_id" {
  type        = string
  description = "ID do recurso google_api_gateway_gateway (e prefixo dos recursos do LB de entrada)."
  default     = "tech-challenge"
}

variable "gateway_entry_ip_name" {
  type        = string
  description = "Nome do IP global da entrada publica (apex → API Gateway via HTTPS LB)."
  default     = "tech-challenge-entry"
}
