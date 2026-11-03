# ADR 004: Gateway do GKE como backend HTTPS

**Data:** 30 de Outubro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

Substitui a [ADR 003](003-cloud-run-auth-gen1.md). Substitui paths, backends e certificado do cluster da [ADR 002](002-api-gateway.md); o produto API Gateway permanece. Estende o ciclo `tf-destroy` da [ADR 001](001-gke-autopilot-tf-destroy.md) com a limpeza do Gateway e das `HTTPRoute` antes do destroy do cluster.

## 1. Contexto e Problema

A entrada pública continua no apex, no HTTPS LB na frente do API Gateway. O API Gateway só chama um backend HTTPS com certificado válido. O Cloud Run `auth` e o Ingress de um único serviço deixam de ser esses backends: os prefixos públicos (`/ordem-servico`, `/estoque`, `/orcamento`, `/administrativo`, `/autenticacao`) e o webhook `/orcamento/webhook/mercado-pago` precisam chegar no cluster, e `/system` não entra nessa borda.

O problema a ser resolvido é: **Como o cluster expõe um único HTTPS para o API Gateway, com IP estático e certificado, sem o `plan` de PR depender do cluster estar ligado?**

## 2. Decisão

- **Backend:** um Gateway do GKE, classe `gke-l7-global-external-managed`, no namespace `tech-challenge`, nome `public`. IP global já reservado `tech-challenge-api`. Hostname `api.<domínio>`. Certificado managed SSL do Compute (`tech-challenge-api-cert`), referenciado por `networking.gke.io/pre-shared-certs`.
- **Objeto Gateway:** manifesto em [`terraform/gke-gateway.yaml.tpl`](../../terraform/gke-gateway.yaml.tpl), aplicado com `kubectl` no `tf-apply`, depois que o cluster existe. Não entra no state. O `plan` de PR não fala com a API do Kubernetes.
- **Listeners:** `http` redireciona para HTTPS (`HTTPRoute` `https-redirect` neste repo). `https` aceita `HTTPRoute` do mesmo namespace. O `HTTPRoute` de cada serviço referencia `sectionName: https` e mora no repositório do serviço.
- **API Gateway:** repassa o path inteiro para `https://api.<domínio>`. Prefixo exato e `/{path=**}` de cada serviço, métodos GET, POST, PUT, PATCH e DELETE, `disable_auth: true`. O webhook do Mercado Pago é path explícito e anônimo. Sem `/system`.
- **Identidade:** um binding `roles/iam.workloadIdentityUser` por service account de runtime do `infra-bootstrap`. A KSA tem o mesmo nome que o account id, no namespace `tech-challenge`.
- **Destroy:** apaga `HTTPRoute` e o Gateway, varre `Service` `LoadBalancer` e `Ingress`, e só então destrói o cluster se não restar forwarding rule no IP `tech-challenge-api`.

## 3. Justificativa

* O certificado managed do Compute é global e encaixa na classe global. A classe regional não aceita esse certificado.
* O hostname `api.<domínio>` e o IP `tech-challenge-api` já eram o backend HTTPS. Reusá-los evita um segundo IP de cluster.
* O provider Kubernetes no Terraform consulta o endpoint do cluster no `plan`. Entre as janelas o cluster não existe, e o control plane é só DNS. O manifesto no workflow preserva o `plan` com o cluster desligado.
* Apagar o objeto no cluster não espera a forwarding rule da GCP. A espera fica no `tf-destroy`, no mesmo lugar em que a ADR 001 já limpava Ingress e `LoadBalancer`.
* O cluster continua nascendo e morrendo na janela. A taxa de um Autopilot vazio não justifica deixá-lo permanente no `infra-bootstrap`.

## 4. Alternativas Consideradas

* **Provider Kubernetes no Terraform:** o Gateway entraria no state. O `plan` quebraria com o cluster desligado, e o destroy ainda precisaria esperar a forwarding rule.
* **Cluster permanente no `infra-bootstrap`:** o endpoint existiria para o provider. A taxa de gerenciamento é de US$ 0,10/hora; o free tier cobre um Autopilot por billing account, e não cobre pod. Um pod esquecido cobraria até alguém apagá-lo. O destroy do cluster é o que corta isso hoje.
* **Certificate Manager:** também gratuito, e pede outra API. O managed SSL do Compute já é o certificado do LB do apex.
* **Classe `gke-l7-gxlb`:** também global, produto clássico. A managed é a classe indicada pelo GKE para o Application Load Balancer externo atual.
* **Cloud Run `auth`:** caminho da ADR 003. A autenticação passa a ser serviço no cluster.

## 5. Consequências

### Positivas
* Um backend HTTPS para todos os prefixos públicos. `/system` não atravessa o API Gateway.
* `fmt` / `validate` / `plan` seguem sem cluster no ar.
* O contrato do `HTTPRoute` (nome `public`, listener `https`, namespace `tech-challenge`) fica estável para os repositórios dos serviços.

### Negativas / Riscos (Mitigações)
* **Dois load balancers globais na janela** (apex e Gateway do GKE), os dois por hora.
  * *Mitigação:* os dois saem no `tf-destroy`. Sem `HTTPRoute` de serviço não há pod.
* **Certificado managed só fica Active depois que o DNS aponta para o IP e o Gateway anexou o certificado.**
  * *Mitigação:* o `tf-apply` imprime o status. O API Gateway responde erro no backend até o status ser Active.
* **O Gateway não está no state.** Alguém pode alterá-lo no cluster e o próximo `tf-apply` reaplica o manifesto.
  * *Mitigação:* o arquivo no repositório é a fonte. O `tf-apply` faz `kubectl apply` de novo.
* **Esquecer o `tf-destroy`** deixa os dois LBs e o Autopilot ligados.
  * *Mitigação:* o workflow falha se a forwarding rule do IP do Gateway continuar existindo, e não segue para o destroy do cluster.
