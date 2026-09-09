# infra-k8s

Terraform + manifests do **GKE Autopilot** e do deploy da API na GCP — Tech Challenge FIAP ([fiap-vcosta](https://github.com/fiap-vcosta)).

## Escopo

- Cluster GKE Autopilot regional `tech-challenge-gke` em `us-central1`, VPC-native na rede do `infra-bootstrap`
- Control plane só por **DNS endpoint** (autenticação IAM), sem endpoint IP
- Binding de Workload Identity da service account Kubernetes da API sobre a service account de runtime
- Manifests da API em [`k8s/`](k8s/): namespace, service account, ConfigMap, Deployment com sidecar do Cloud SQL Auth Proxy, Service `LoadBalancer` e HPA
- State remoto em GCS (o bucket é do `infra-bootstrap` e não morre no destroy)

A rede não está aqui: VPC, subnet e os ranges secundários de pods/services vêm do [`infra-bootstrap`](https://github.com/fiap-vcosta/infra-bootstrap) via `terraform_remote_state`. O banco é do [`infra-db`](https://github.com/fiap-vcosta/infra-db). Kind / self-hosted não são caminho de entrega.

Root module: [`terraform/`](terraform/).

## Entrada HTTP

`Service type: LoadBalancer` (L4 externo, HTTP na porta 80). API Gateway continua no radar: com backend no GKE ele exige URL pública HTTPS com certificado válido, ou seja, domínio — decisão que fica para a ADR de entrada junto com as rotas da Function `auth`.

## Caminho até o Cloud SQL

O pod fala com o banco por **Cloud SQL Auth Proxy** rodando como sidecar nativo (init container com `restartPolicy: Always`), o que garante que o proxy esteja pronto antes do container da API subir — a API roda as migrations no start e falharia se o túnel ainda não existisse.

O proxy autentica na instância por IAM, usando a service account de runtime (`roles/cloudsql.client`) via Workload Identity, e escuta em `127.0.0.1:5432` com `--private-ip`. A API só conhece `localhost`, o que mantém a connection string trivial e o tráfego dentro do pod.

Contrato com o `infra-bootstrap`: namespace `tech-challenge` e service account Kubernetes `api`. O binding em [`terraform/workload-identity.tf`](terraform/workload-identity.tf) e a anotação em [`k8s/serviceaccount.yaml`](k8s/serviceaccount.yaml) precisam concordar, senão o sidecar sobe e falha na autenticação.

O binding mora aqui, e não no bootstrap, porque o pool `PROJECT.svc.id.goog` só existe enquanto há cluster com Workload Identity no projeto: ele nasce e morre com a demo.

## Secret esperado pelo Deployment

O Deployment consome um Secret `api` no namespace `tech-challenge` que **não** está neste repo — ele é criado pelo workflow de deploy do repo `api`, que lê a senha do Secret Manager e gera a chave JWT no momento do deploy:

| Chave | Conteúdo |
|-------|----------|
| `ConnectionStrings__DefaultConnection` | Connection string apontando para `127.0.0.1:5432` (o sidecar) |
| `Jwt__Key` | Chave de assinatura do JWT de staff |

## CI vs CD

| Tipo | Quando | Automático? |
|------|--------|-------------|
| **CI** `fmt` + `validate` | PR / push | Sim ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) |
| **CI** `plan` (OIDC) | PR | Sim |
| **`tf-apply` / `tf-destroy`** | Janela da demo | Só manual (`workflow_dispatch`) |

Merge em `main` **nunca** liga o cluster.

O `tf-destroy` apaga o Service `LoadBalancer` antes do `terraform destroy`: apagar o cluster com o Service de pé pode deixar forwarding rule órfão, que é cobrado por hora mesmo sem tráfego.

Org vars consumidas: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT_EMAIL`, `GCP_GKE_CLUSTER_NAME` e `GCP_REGION`. Os workflows falham cedo se alguma vier vazia, em vez de aplicar silenciosamente o default do código.

## Comandos

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

Os manifests usam `${IMAGE}` como placeholder da imagem; o deploy resolve com `envsubst`:

```bash
IMAGE=us-central1-docker.pkg.dev/vcosta-fiap-tech-challenge/tech-challenge/api:TAG \
  envsubst '${IMAGE}' < k8s/deployment.yaml | kubectl apply -f -
```

Acesso ao cluster (control plane só por DNS endpoint):

```bash
gcloud container clusters get-credentials tech-challenge-gke \
  --region us-central1 --dns-endpoint
```

## Ordem na demo

1. `infra-db` → `tf-apply`
2. Este repo → `tf-apply` (Autopilot leva ~5–10 min)
3. `api` → `deploy`
4. Destroy inverso: este repo → `infra-db`

O `infra-bootstrap` é pré-requisito aplicado uma vez e não entra nesse ciclo.

## Agentes

Ver [AGENTS.md](AGENTS.md).
