terraform {
  backend "gcs" {
    bucket = "vcosta-fiap-tech-challenge-tfstate"
    prefix = "infra-k8s"
  }
}
