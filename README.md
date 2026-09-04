# infra-k8s

Terraform + manifests para **GKE Autopilot**, entrada (API Gateway se couber) e deploy da API na GCP — Tech Challenge FIAP ([fiap-vcosta](https://github.com/fiap-vcosta)).

## Escopo

- GKE Autopilot
- Entrada HTTP (Gateway e/ou LB)
- Manifests da API no cluster
- Região `us-central1`
- State remoto em GCS (bootstrap fora deste stack)

Root module: [`terraform/`](terraform/). Kind / self-hosted não são caminho de entrega.

## CI vs CD

| Tipo | Quando | Automático? |
|------|--------|-------------|
| **CI** `fmt` + `validate` | PR / push | Sim ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) |
| **`tf-apply` / `tf-destroy`** | Janela da demo | Só manual (`workflow_dispatch`) |

Merge em `main` **nunca** liga o cluster.

## Comandos

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

## Ordem na demo

1. `infra-db` → `tf-apply`
2. Este repo → `tf-apply`
3. Deploy API (e auth quando existir)
4. Destroy inverso: este repo → `infra-db`

## Agentes

Ver [AGENTS.md](AGENTS.md).
