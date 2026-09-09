resource "google_service_account_iam_member" "api_runtime" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${data.terraform_remote_state.bootstrap.outputs.api_runtime_service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"

  depends_on = [google_container_cluster.main]
}
