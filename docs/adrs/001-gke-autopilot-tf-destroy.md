# ADR 001: GKE Autopilot e Ciclo `tf-destroy`

**Data:** 10 de Setembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

A API precisa rodar na GCP com escala horizontal demonstrável (HPA), na mesma VPC do Cloud SQL, com identidade para o Auth Proxy. O cluster é o maior custo da demo: deve ligar só na janela e sumir no destroy.

O problema a ser resolvido é: **Qual modo de GKE usamos, e como o destroy garante que nada caro (nem órfão de cobrança) sobreviva à demo?**

## 2. Decisão

- **Cluster:** GKE **Autopilot** regional `tech-challenge-gke` em `us-central1`, VPC-native (rede do `infra-bootstrap`), nós privados.
- **Control plane:** **DNS-only** (acesso por DNS + IAM; sem endpoint IP nem lista de IPs autorizados).
- **Escopo deste repo:** cluster + binding de Workload Identity da KSA da API. **Manifests da aplicação ficam no repo `api`.**
- **Ciclo de vida:** `tf-apply` / `tf-destroy` **manuais** (`workflow_dispatch`). `tf-destroy` apaga o state inteiro deste stack (sem carve-outs) e, **antes** do destroy, remove Services `LoadBalancer` do cluster para não deixar forwarding rule órfã cobrada.

## 3. Justificativa

* **Autopilot** reduz operação de nós e cobra mais perto do uso dos pods — adequado a poucos minutos no ar + stress pontual de HPA.
* **DNS-only** evita bastion e allowlist de IP para CI/máquina local; autenticação é IAM.
* **Separação cluster × workload:** este repo não vira monorepo de YAML; a `api` versiona manifests com o código e o deploy.
* **Destroy sem carve-outs** mantém state = nuvem; recriar no próximo apply é aceitável. Apagar LBs antes evita cobrança residual conhecida do GKE.

## 4. Alternativas Consideradas

* **GKE Standard:** controle fino de nós; paga VMs o tempo todo o cluster existir — pior para demo curta.
* **Cloud Run para a API:** escala a zero; foge do requisito de HPA/Kubernetes do enunciado.
* **Kind / self-hosted:** rejeitados como caminho de entrega na nuvem.
* **Carve-outs no destroy** (proteger resources com `prevent_destroy`): rejeitado — state mentiria e órfãos acumulariam.
* **Control plane com IP público + authorized networks:** mais familiar; exige manter allowlist e complica CI.

## 5. Consequências

### Positivas
* Merge em `main` nunca liga o cluster.
* Workload Identity do binding mora aqui (pool `svc.id.goog` só existe com cluster vivo).
* Demo-down previsível: destroy k8s → destroy db.

### Negativas / Riscos (Mitigações)
* **Esquecer o destroy** deixa Autopilot sangrando.
  * *Mitigação:* processo demo-down obrigatório; destroy manual ao fim da janela.
* **Contrato namespace/`ServiceAccount` com a `api`:** mismatch só aparece em runtime.
  * *Mitigação:* valores documentados no README; binding e manifests devem usar os mesmos nomes.
