# Tech Challenge — Guia para agentes (`infra-k8s`)

Terraform + manifests para **GKE Autopilot**, API Gateway (se couber) e deploy da API na GCP. Org [fiap-vcosta](https://github.com/fiap-vcosta). Banco em `infra-db`; Function em `auth`.

## Antes de mudar código

1. Ler ADRs deste repo (quando existirem) e decisões Autopilot/Gateway/custo da Fase 03
2. Espelhar módulos/manifests vizinhos; não inventar layout paralelo
3. Não rodar `apply`/`destroy`/deploy sem confirmação explícita do usuário
4. **Git:** nunca commit/push direto em `main` — branch → PR → merge (ver [`.cursor/rules/git-workflow.mdc`](.cursor/rules/git-workflow.mdc))

## Responsabilidade

| Peça | Papel |
|------|--------|
| Terraform | Cluster Autopilot, Gateway/entrada, addons mínimos |
| Manifests | Deploy da API (e correlatos) no cluster |
| State | Backend remoto **persistente** entre demos |
| Fora de escopo | Cloud SQL, código da Function auth, regras de domínio da oficina |

## Regras canônicas (resumo)

- Autopilot; apply/destroy/deploy manuais
- State não morre no destroy da demo
- Sem secrets no Git; Kind não é entrega

## Comandos

```bash
terraform fmt -check
terraform validate
# plan/apply/destroy e kubectl: só com confirmação humana / workflow_dispatch
```
