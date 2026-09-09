# Tech Challenge — Guia para agentes (`infra-k8s`)

Terraform + manifests para **GKE Autopilot** e deploy da API na GCP. Org [fiap-vcosta](https://github.com/fiap-vcosta). Rede e WIF em `infra-bootstrap`; banco em `infra-db`; Function em `auth`.

## Antes de mudar código

1. Ler ADRs deste repo (quando existirem) e decisões Autopilot/Gateway/custo da Fase 03
2. Espelhar módulos/manifests vizinhos; não inventar layout paralelo
3. Não rodar `apply`/`destroy`/deploy sem confirmação explícita do usuário
4. **Git:** nunca commit/push direto em `main` — branch → PR → merge (ver [`.cursor/rules/git-workflow.mdc`](.cursor/rules/git-workflow.mdc))

## Responsabilidade

| Peça | Papel |
|------|--------|
| Terraform | Cluster Autopilot, binding de Workload Identity da KSA da API |
| Manifests | `k8s/`: namespace, KSA, ConfigMap, Deployment com sidecar do proxy, Service LoadBalancer, HPA |
| Rede | **Consumida** do `infra-bootstrap` via `terraform_remote_state` |
| State | Backend remoto **persistente** entre demos |
| Fora de escopo | VPC/subnet/PSA, Cloud SQL, imagem e workflows de deploy da API, Function auth |

## Regras canônicas (resumo)

- Autopilot; apply/destroy/deploy manuais
- Rede não se cria aqui; se falta algo na VPC, o PR é no `infra-bootstrap`
- Namespace `tech-challenge` e KSA `api` são contrato entre `terraform/workload-identity.tf` e `k8s/serviceaccount.yaml`
- Secret `api` não vive no Git: o deploy do repo `api` o cria a partir do Secret Manager
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
