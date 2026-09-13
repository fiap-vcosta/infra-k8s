# Tech Challenge — Guia para agentes (`infra-k8s`)

Terraform do **GKE Autopilot** que hospeda a API na GCP. Org [fiap-vcosta](https://github.com/fiap-vcosta). Rede e WIF em `infra-bootstrap`; banco em `infra-db`; manifests e deploy no repo `api`; Function em `auth`.

## Antes de mudar código

1. Ler ADRs em [`docs/adrs/`](docs/adrs/) e decisões Autopilot/Gateway/custo já tomadas
2. Espelhar módulos/manifests vizinhos; não inventar layout paralelo
3. Não rodar `apply`/`destroy`/deploy sem confirmação explícita do usuário
4. **Git:** nunca commit/push direto em `main` — branch → PR → merge (ver [`.cursor/rules/git-workflow.mdc`](.cursor/rules/git-workflow.mdc))

## Responsabilidade

| Peça | Papel |
|------|--------|
| Terraform | Cluster Autopilot, binding WI da KSA da API, Cloud Run `auth` |
| Rede | **Consumida** do `infra-bootstrap` via `terraform_remote_state` |
| State | Backend remoto **persistente** entre demos |
| Fora de escopo | Manifests/deploy da API (repo `api`), código/imagem do auth (repo `auth` só `build-push`), VPC/subnet/PSA, Cloud SQL |

## Regras canônicas (resumo)

- Autopilot; apply/destroy manuais
- **YAML de aplicação da API não mora aqui**; o serviço Cloud Run do auth sim (mesmo ciclo da demo)
- Rede não se cria aqui; se falta algo na VPC, o PR é no `infra-bootstrap`
- Namespace `tech-challenge` e KSA `api` são contrato com os manifests do repo `api`
- State não morre no destroy da demo
- Sem secrets no Git; Kind não é entrega

## Comandos

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
# plan/apply/destroy e kubectl: só com confirmação humana / workflow_dispatch
```
