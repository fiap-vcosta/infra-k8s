# ADR 002: API Gateway como Entrada HTTP

**Data:** 10 de Setembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

Na demo queremos um ponto de entrada único para o cliente (`/auth` → Function CPF→JWT) e para a API (`/api`), em vez de expor URLs soltas. O Terraform do gateway vive neste repo (`infra-k8s`), junto do cluster. Hoje a API sobe com `Service type: LoadBalancer` (HTTP) no repo `api` — suficiente para o 1º smoke.

O problema a ser resolvido é: **Usamos GCP API Gateway na frente de `/auth` e `/api`? Sob quais restrições?**

## 2. Decisão

- **Produto:** **GCP API Gateway**, Terraform neste repo, preferência por gateway único com rotas `/auth` e `/api`.
- **Validação de custo na execução:** se o preço na janela de demo não couber, manter LB (ou outro front barato) e documentar o desvio.
- **Ordem:** 1º smoke pode ser só API/health via LoadBalancer; rotas `/auth` entram quando a Function existir.
- **Restrição explícita (backend GKE):** API Gateway na frente de um backend no GKE exige **URL pública HTTPS com certificado válido** — ou seja, **domínio** (e certificado gerenciado/adequado). IP HTTP nu de um `LoadBalancer` **não** satisfaz esse requisito tipicamente. Sem domínio/cert, o gateway completo fica bloqueado; o LB da API continua como entrada temporária/aceitável para smoke.

## 3. Justificativa

* Casa com o desenho de entrada única do enunciado e separa auth cliente (Function) da API.
* Terraform no `infra-k8s` mantém a borda HTTP perto do cluster (mesmo ciclo de demo).
* Registrar a restrição de HTTPS+domínio evita surpresa na implementação e explica por que o 1º smoke usou LB.

## 4. Alternativas Consideradas

* **Só LoadBalancer / Ingress sem API Gateway:** mais simples e barato; atende smoke; perde o “gateway único” acadêmico se for a entrega final.
* **Cloud Load Balancing + URL map manual:** flexível; mais peças e custo operacional que API Gateway para o escopo da demo.
* **Expor Function e API em URLs separadas sem front comum:** funciona; pior narrativa de arquitetura e de vídeo.
* **Gateway sem domínio (só IP HTTP):** incompatível com o requisito usual de backend HTTPS do API Gateway → GKE.

## 5. Consequências

### Positivas
* Decisão de produto fechada; implementação pode seguir na mesma janela da Function.
* Smoke precoce desbloqueado sem esperar domínio.
* Custo do gateway permanece sob avaliação consciente.

### Negativas / Riscos (Mitigações)
* **Dependência de domínio + certificado** para fechar `/api` via Gateway.
  * *Mitigação:* obter domínio (ou desistir do Gateway na entrega e declarar LB no README/vídeo); não inventar HTTP-only atrás do Gateway.
* **Custo extra** na janela.
  * *Mitigação:* validar na execução; Budget R$ 50; destroy remove o que este state criar.
* **OpenAPI / config do Gateway** a definir na implementação (paths exatos).
  * *Mitigação:* alinhar com Swagger/Requestly da `api` e contrato do repo `auth`.
