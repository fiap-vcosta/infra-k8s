data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = "vcosta-fiap-tech-challenge-tfstate"
    prefix = "infra-bootstrap"
  }
}
