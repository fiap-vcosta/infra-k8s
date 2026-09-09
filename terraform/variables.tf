variable "project_id" {
  type        = string
  description = "GCP project ID da demo."
  default     = "vcosta-fiap-tech-challenge"
}

variable "region" {
  type        = string
  description = "Região primária (fechada na Fase 03)."
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
  description = "Namespace da API; contrato com os manifests em k8s/."
  default     = "tech-challenge"
}

variable "k8s_service_account" {
  type        = string
  description = "Service account Kubernetes da API; contrato com os manifests em k8s/."
  default     = "api"
}
