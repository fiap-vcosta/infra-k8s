# ADR 003: Cloud Run `auth` com GEN1, 128Mi e `cpu_idle`

**Data:** 14 de Setembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

O serviço HTTP de autenticação de cliente (documento → JWT) sobe e desce com este stack, na mesma janela da demo do Autopilot. Cada segundo ligado custa; o tráfego é pontual (poucos requests no vídeo).

O problema a ser resolvido é: **Qual execution environment, memória e modelo de CPU usamos no Cloud Run `auth` para custo mínimo na demo, sem confundir isso com o produto “Cloud Functions 2nd gen” do enunciado?**

## 2. Decisão

- **Compute:** Cloud Run (imagem Docker do repo [`auth`](https://github.com/fiap-vcosta/auth)), ciclo `tf-apply` / `tf-destroy` neste repo.
- **Execution environment:** `EXECUTION_ENVIRONMENT_GEN1`.
- **Memória:** `128Mi` (mínimo viável para Node 22 + Functions Framework nesta Function pequena).
- **CPU:** `cpu_idle = true` (billing *request-based*: CPU alocada só durante o request; escala a zero fora da janela).
- **Não** confundir: o enunciado fala em “Function”; o produto GCP “Cloud Functions 2nd gen” roda em cima de Cloud Run. Aqui entregamos o **serviço Cloud Run** diretamente. GEN1/GEN2 neste ADR é o *execution environment* do Cloud Run (`template.execution_environment`), não a geração do produto Functions.

## 3. Justificativa

* GEN1 + 128Mi + `cpu_idle` mantém o auth no menor perfil cobrado da plataforma para um HTTP efêmero.
* Escala a zero (`min_instance_count = 0`) casa com demo de minutos: fora da janela o custo tende a zero.
* Imagem no Artifact Registry (`:latest`) separa build (repo `auth`) do ciclo de vida (este stack).
* Documentar a distinção Functions 2nd gen × GEN1/GEN2 evita leitura errada na apresentação e no código Terraform.

## 4. Alternativas Consideradas

* **Cloud Functions 2nd gen (produto):** atende o enunciado ao pé da letra; na prática empacota o mesmo runtime em Cloud Run com peças extras (Eventarc/Build). Rejeitado como caminho oficial — Cloud Run direto é mais simples e já cobre HTTP.
* **Execution environment GEN2:** melhor isolamento e features novas; custo/overhead desnecessário para esta Function pequena na demo.
* **Memória maior (256Mi+) ou CPU always-allocated (`cpu_idle = false`):** sobra margem; sangra na janela sem ganho perceptível no smoke.
* **min instances > 0:** elimina cold start; cobra idle o tempo todo — pior para demo curta.

## 5. Consequências

### Positivas

* Auth barato e alinhado ao destroy da demo.
* ADR deixa explícito o que o Terraform já aplica em [`terraform/auth.tf`](../../terraform/auth.tf).

### Negativas / Riscos (Mitigações)

* **Cold start** no primeiro request após escala a zero.
  * *Mitigação:* aceitável na demo; smoke pode incluir um `POST /auth` de aquecimento.
* **128Mi apertado** se o handler crescer (dependências pesadas).
  * *Mitigação:* subir `auth_memory` via variável; revisitar só se o runtime OOM.
* **Vocabulário “Function” vs Cloud Run** pode confundir na banca.
  * *Mitigação:* este ADR + README; na fala: “HTTP efêmero no Cloud Run, no espírito da Function do enunciado”.
