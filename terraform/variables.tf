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
variable "artifact_registry_repository" {
  type        = string
  description = "Repositório Docker do Artifact Registry (org var GCP_AR_REPOSITORY)."
  default     = "tech-challenge"
}

variable "auth_service_name" {
  type        = string
  description = "Nome do serviço Cloud Run do auth."
  default     = "auth"
}

variable "auth_api_base_url" {
  type        = string
  description = "URL pública da API consultada pelo auth (var/input API_BASE_URL)."
}

variable "auth_jwt_cliente_key" {
  type        = string
  description = "Secret HS256 do JWT cliente (mesmo material da API)."
  sensitive   = true
}

variable "auth_jwt_cliente_issuer" {
  type        = string
  description = "Issuer do JWT cliente."
  default     = "tech-challenge-cliente"
}

variable "auth_jwt_cliente_audience" {
  type        = string
  description = "Audience do JWT cliente."
  default     = "tech-challenge-cliente"
}

variable "auth_service_auth_key" {
  type        = string
  description = "Shared secret do header X-Service-Key."
  sensitive   = true
}

variable "auth_memory" {
  type        = string
  description = "Limite de memória do container auth."
  default     = "256Mi"
}

variable "auth_cpu" {
  type        = string
  description = "Limite de CPU do container auth."
  default     = "1"
}

variable "auth_timeout" {
  type        = string
  description = "Timeout da requisição do auth."
  default     = "60s"
}

variable "auth_max_instance_count" {
  type        = number
  description = "Máximo de instâncias do auth."
  default     = 2
}

variable "api_static_ip_name" {
  type        = string
  description = "Nome do IP global reservado para o Ingress HTTPS da API."
  default     = "tech-challenge-api"
}
