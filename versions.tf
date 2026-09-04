terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Backend GCS: configurar na §4/§5 (bucket de state é bootstrap fora deste stack).
}
