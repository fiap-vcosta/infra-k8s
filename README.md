# infra-k8s

Terraform do **GKE Autopilot** que hospeda a API na GCP — Tech Challenge FIAP ([fiap-vcosta](https://github.com/fiap-vcosta)).

## Escopo

- Cluster GKE Autopilot regional `tech-challenge-gke` em `us-central1`, VPC-native na rede do `infra-bootstrap`
- Control plane só por **DNS endpoint** (autenticação IAM), sem endpoint IP
- Binding de Workload Identity da service account Kubernetes da API sobre a service account de runtime
- State remoto em GCS (o bucket é do `infra-bootstrap` e não morre no destroy)

Este stack entrega **cluster e identidade**, não workload: os manifests da API (Deployment, Service, HPA, ConfigMap, namespace e service account) vivem no repo [`api`](https://github.com/fiap-vcosta/api), ao lado do código e do workflow que os aplica. A rede vem do [`infra-bootstrap`](https://github.com/fiap-vcosta/infra-bootstrap) via `terraform_remote_state`; o banco é do [`infra-db`](https://github.com/fiap-vcosta/infra-db). Kind / self-hosted não são caminho de entrega.

Root module: [`terraform/`](terraform/).

## Contrato com o repo `api`

O binding em [`terraform/workload-identity.tf`](terraform/workload-identity.tf) autoriza uma service account Kubernetes específica a assumir a service account GCP de runtime:

| Valor | Onde vive aqui | Onde vive na `api` |
|-------|----------------|--------------------|
| Namespace `tech-challenge` | `var.k8s_namespace` | `metadata.namespace` dos manifests |
| Service account `api` | `var.k8s_service_account` | `ServiceAccount` + `serviceAccountName` do pod |
| E-mail da SA de runtime | remote state do bootstrap | anotação `iam.gke.io/gcp-service-account` |

Renomear namespace ou service account de um lado sem o outro **não** quebra `plan` nem `apply`: o binding continua válido apontando para uma identidade que não existe, e o sintoma aparece só em runtime, com o Cloud SQL Auth Proxy falhando na autenticação.

O binding mora aqui, e não no `infra-bootstrap`, porque o pool `PROJECT.svc.id.goog` só existe enquanto há cluster com Workload Identity no projeto: ele nasce e morre com a demo.

## Entrada HTTP

A API é exposta por um `Service type: LoadBalancer` (L4 externo, HTTP) declarado no repo `api`. API Gateway continua no radar: com backend no GKE ele exige URL pública HTTPS com certificado válido, ou seja, domínio — decisão que fica para a ADR de entrada junto com as rotas da Function `auth`.

## Acesso ao cluster

O control plane não tem endpoint IP; o acesso é pelo DNS endpoint, autenticado por IAM:

```bash
gcloud container clusters get-credentials tech-challenge-gke \
  --region us-central1 --dns-endpoint
```

## CI vs CD

| Tipo | Quando | Automático? |
|------|--------|-------------|
| **CI** `fmt` + `validate` | PR / push | Sim ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) |
| **CI** `plan` (OIDC) | PR | Sim |
| **`tf-apply` / `tf-destroy`** | Janela da demo | Só manual (`workflow_dispatch`) |

Merge em `main` **nunca** liga o cluster.

O `tf-destroy` apaga todo `Service type: LoadBalancer` do cluster antes do `terraform destroy`: destruir o cluster com um deles de pé pode deixar forwarding rule órfão, que é cobrado por hora mesmo sem tráfego. A varredura é por tipo, não por nome, justamente porque os manifests não são deste repo.

Org vars consumidas: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT_EMAIL`, `GCP_GKE_CLUSTER_NAME` e `GCP_REGION`. Os workflows falham cedo se alguma vier vazia, em vez de aplicar silenciosamente o default do código.

## Comandos

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

## Ordem na demo

1. `infra-db` → `tf-apply`
2. Este repo → `tf-apply` (Autopilot leva ~5–10 min)
3. `api` → `deploy`
4. Destroy inverso: este repo → `infra-db`

O `infra-bootstrap` é pré-requisito aplicado uma vez e não entra nesse ciclo.

## Agentes

Ver [AGENTS.md](AGENTS.md).
