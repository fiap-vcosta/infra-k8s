# infra-k8s

Terraform + manifests para **GKE Autopilot**, entrada (API Gateway se couber) e deploy da API na GCP — Tech Challenge FIAP ([fiap-vcosta](https://github.com/fiap-vcosta)).

## Escopo

| Inclui | Não inclui |
|--------|------------|
| GKE Autopilot, Gateway/LB, manifests da API (§5) | Cloud SQL (repo `infra-db`) |
| Entrada HTTP da demo | Function auth (repo `auth`); regras de domínio da oficina |

- Região: **`us-central1`**
- Cluster: **Autopilot** (fechado)
- Kind / self-hosted: **não** são entrega da Fase 03 (legado na `api`)
- State remoto GCS: bootstrap **fora** deste stack

## CI vs CD

| Tipo | Quando | Automático? |
|------|--------|-------------|
| **CI** `fmt` + `validate` | PR / push | Sim ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) |
| **`tf-apply` / `tf-destroy`** | Janela da demo | Só manual (`workflow_dispatch`) — §5 |

Merge em `main` **nunca** liga o cluster.

## Layout atual (§3)

Scaffold Terraform vazio (válido para `validate`). GKE, Gateway e manifests entram na **§5**.

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

## Ordem na demo

1. `infra-db` → `tf-apply`
2. Este repo → `tf-apply`
3. Deploy API (e auth quando existir)
4. Destroy inverso: este repo → `infra-db`

Ver processo em `local/FASE03-PROCESSO-DEMO.md` (workspace local).

## Agentes

Ver [AGENTS.md](AGENTS.md).
