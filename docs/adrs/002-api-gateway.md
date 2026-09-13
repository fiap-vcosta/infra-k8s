# ADR 002: API Gateway como Entrada HTTP

**Data:** 10 de Setembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

Na demo queremos um ponto de entrada único para o cliente (`/auth` → Function CPF→JWT) e para a API (`/api`), em vez de expor URLs soltas. O Terraform do gateway vive neste repo (`infra-k8s`), junto do cluster. Hoje a API sobe com `Service type: LoadBalancer` (HTTP) no repo `api` — suficiente para o 1º smoke.

O problema a ser resolvido é: **Usamos GCP API Gateway na frente de `/auth` e `/api`? Como satisfazer o backend HTTPS exigido para a API no GKE?**

## 2. Decisão

- **Produto:** **GCP API Gateway**, Terraform neste repo, gateway único com rotas `/auth` e `/api`.
- **Caminho oficial (HTTPS nomeado):** domínio barato + Cloud DNS (zona no `infra-bootstrap`; records `api`/`auth` neste repo) + **certificado gerenciado** (Ingress no repo `api`) → backend do API Gateway em `https://…` para a API; Cloud Run auth (já HTTPS, com hostname custom) como backend de `/auth`.
- **Ordem:** 1º smoke e desenvolvimento cedo usam LoadBalancer HTTP; domínio/cert + Gateway completo entram na janela da Function (`auth`), antes da demo gravável.
- **Restrição:** o API Gateway chama uma **URL de backend**. Para a API no GKE essa URL precisa ser **HTTPS público com certificado válido em um nome DNS**. Um LoadBalancer que só expõe `http://IP` **não serve** como backend tipicamente.

## 3. Justificativa

* Casa com o desenho de entrada única do enunciado e separa auth cliente (Function) da API.
* Terraform no `infra-k8s` mantém a borda HTTP perto do cluster (mesmo ciclo de demo).
* Domínio + cert gerenciado é o caminho que desbloqueia `/api` no Gateway sem gambiarra; custo de domínio é baixo (anual) e o Gateway em tráfego de demo cabe no free tier de calls.
* Smoke com LoadBalancer permanece válido até o HTTPS nomeado existir.

## 4. Alternativas Consideradas

* **Só LoadBalancer / Ingress sem API Gateway:** mais simples; perde o gateway único acadêmico — rejeitado como entrega alvo.
* **Cloud Load Balancing + URL map** (sem API Gateway): entrada única com TLS possível; mais peças e foge do produto “API Gateway” do enunciado.
* **URLs separadas** (Function HTTPS + API no LB) ou **Gateway só em `/auth`:** planos B se domínio/cert travarem prazo; **não** são o alvo.
* **Apontar o Gateway para `http://IP` da API:** rejeitado — não atende o requisito usual de backend HTTPS do produto.

## 5. Consequências

### Positivas
* Entrada única `/auth` + `/api` na demo e no vídeo.
* Smoke precoce desbloqueado sem esperar domínio.
* Decisão explícita: investir tempo em DNS + cert + Gateway (ver estimativa local da fase).

### Negativas / Riscos (Mitigações)
* **Tempo de implementação** (domínio, DNS, cert, OpenAPI/Terraform do Gateway, debug).
  * *Mitigação:* bloco dedicado no cronograma (~8–16 h, ponto médio ~12 h) além do scaffold da Function; comprar domínio cedo.
* **Custo:** domínio (~dezenas de R$/ano) + LB/Ingress HTTPS só na janela; calls do Gateway ~R$ 0 na demo (free tier).
  * *Mitigação:* maximizar free tier; `tf-destroy` remove Gateway/LB da demo; domínio pode ficar (barato) ou não renovar.
* **OpenAPI / paths exatos** na execução.
  * *Mitigação:* alinhar com Swagger/Requestly da `api` e contrato do repo `auth`.
* **Bloqueio de prazo em DNS/cert:** só então cair para plano B documentado (Gateway só `/auth` ou LB + URL da Function).
