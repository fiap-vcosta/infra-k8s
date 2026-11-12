# Tech Challenge — Guia para agentes (`infra-k8s`)

Terraform do **GKE Autopilot** que hospeda os serviços na GCP. Org [fiap-vcosta](https://github.com/fiap-vcosta). Rede e WIF em `infra-bootstrap`; Cloud SQL no Terraform de cada serviço SQL. O `HTTPRoute` e o deploy de cada serviço ficam no repositório do serviço.

## Antes de mudar código

1. Ler ADRs em [`docs/adrs/`](docs/adrs/) e decisões Autopilot/Gateway/custo já tomadas
2. Espelhar módulos/manifests vizinhos; não inventar layout paralelo
3. Não rodar `apply`/`destroy`/deploy sem confirmação explícita do usuário
4. **Git:** nunca commit/push direto em `main` — branch → PR → merge (ver [`.cursor/rules/git-workflow.mdc`](.cursor/rules/git-workflow.mdc))

## Responsabilidade

| Peça | Papel |
|------|--------|
| Terraform | Cluster Autopilot, bindings WI das cinco KSAs, IP/DNS da janela, certificado de `api.<domínio>`, API Gateway + HTTPS LB no apex |
| Workflow | Aplica e apaga o Gateway do GKE (`terraform/gke-gateway.yaml.tpl`) em volta do `tf-apply` / `tf-destroy` |
| Rede / zona DNS | **Consumidas** do `infra-bootstrap` via `terraform_remote_state` |
| State | Backend remoto **persistente** entre demos |
| Fora de escopo | `HTTPRoute` e deploy de cada serviço, VPC/subnet/PSA, zona Cloud DNS, Cloud SQL |

## Regras canônicas (resumo)

- Autopilot; apply/destroy manuais
- O Gateway do GKE é manifesto deste repo, aplicado no workflow. O `HTTPRoute` público de cada serviço fica no repositório do serviço, no listener `https`
- Rede e zona DNS não se criam aqui; se falta algo na VPC/zona, o PR é no `infra-bootstrap`
- Namespace `tech-challenge`. KSA com o mesmo nome do account id da service account de runtime
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
