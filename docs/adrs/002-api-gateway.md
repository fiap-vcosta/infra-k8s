# ADR 002: API Gateway como Entrada HTTP

**Data:** 10 de Setembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

Na demo queremos um ponto de entrada único para o cliente (`/auth` → Function CPF→JWT) e para a API (`/api`), em vez de expor URLs soltas. O Terraform do gateway vive neste repo (`infra-k8s`), junto do cluster. Hoje a API sobe com `Service type: LoadBalancer` (HTTP) no repo `api` — suficiente para o 1º smoke.

O problema a ser resolvido é: **Usamos GCP API Gateway na frente de `/auth` e `/api`? Sob quais restrições?**

## 2. Decisão

- **Produto:** **GCP API Gateway**, Terraform neste repo, preferência por gateway único com rotas `/auth` e `/api`.
- **Validação de custo na execução:** se o preço na janela de demo não couber, manter o LoadBalancer (ou outro front barato) e documentar o desvio.
- **Ordem:** 1º smoke pode ser só API/health via LoadBalancer; rotas `/auth` entram quando a Function existir.
- **Restrição (API no GKE atrás do Gateway):** o API Gateway não fala com o pod diretamente — ele chama uma **URL de backend**. Para a API no GKE, essa URL precisa ser **HTTPS público com certificado válido em um nome DNS** (ex.: `https://api.exemplo.com`). Um LoadBalancer que só expõe `http://IP` **não serve** como backend tipicamente. Enquanto não houver domínio + certificado na frente da API, o Gateway completo (`/api`) fica pendente; o LoadBalancer HTTP continua válido para smoke e para a demo se o Gateway não couber.

## 3. Justificativa

* Casa com o desenho de entrada única do enunciado e separa auth cliente (Function) da API.
* Terraform no `infra-k8s` mantém a borda HTTP perto do cluster (mesmo ciclo de demo).
* Deixar a restrição explícita evita surpresa na implementação e explica o smoke com LoadBalancer.

## 4. Alternativas Consideradas

* **Só LoadBalancer / Ingress sem API Gateway:** mais simples e barato; atende smoke; perde o “gateway único” acadêmico se for a entrega final.
* **Cloud Load Balancing + URL map** (rotear `/auth` e `/api` sem API Gateway): resolve entrada única com TLS no próprio LB, se houver domínio; mais peças que o API Gateway para o escopo da demo.
* **URLs separadas** (Function HTTPS nativa + API no LB): funciona; pior narrativa de arquitetura e de vídeo.
* **Apontar o Gateway para `http://IP` da API:** rejeitado — não atende o requisito usual de backend HTTPS do produto.

## 5. Consequências

### Positivas
* Decisão de produto fechada; implementação pode seguir na mesma janela da Function.
* Smoke precoce desbloqueado sem esperar domínio.
* Custo do gateway permanece sob avaliação consciente.

### Negativas / Riscos (Mitigações)
* **Sem domínio/cert, `/api` no Gateway não fecha.**
  * *Mitigação (caminhos válidos):* (1) domínio barato + DNS apontando para a API + certificado gerenciado (Ingress/Gateway HTTPS ou LB HTTPS) e aí cadastrar `https://…` como backend do API Gateway; (2) desistir do Gateway na entrega e documentar LB + URL da Function; (3) Gateway só em `/auth` (Function já nasce HTTPS) e API continua no LB — entrada não fica 100% única.
* **Custo extra** na janela.
  * *Mitigação:* validar na execução; maximizar free tier; `tf-destroy` remove o que este state criar.
* **OpenAPI / config do Gateway** a definir na implementação (paths exatos).
  * *Mitigação:* alinhar com Swagger/Requestly da `api` e contrato do repo `auth`.
