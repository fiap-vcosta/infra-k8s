resource "google_service_account_iam_member" "runtime" {
  for_each = data.terraform_remote_state.bootstrap.outputs.runtime_service_account_emails

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${each.key}]"

  depends_on = [google_container_cluster.main]
}
