apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ${GATEWAY_NAME}
  namespace: ${NAMESPACE}
spec:
  gatewayClassName: gke-l7-global-external-managed
  addresses:
    - type: NamedAddress
      value: ${STATIC_IP_NAME}
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      hostname: ${API_HOSTNAME}
      allowedRoutes:
        namespaces:
          from: Same
    - name: https
      protocol: HTTPS
      port: 443
      hostname: ${API_HOSTNAME}
      tls:
        mode: Terminate
        options:
          networking.gke.io/pre-shared-certs: ${SSL_CERTIFICATE_NAME}
      allowedRoutes:
        namespaces:
          from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-redirect
  namespace: ${NAMESPACE}
spec:
  parentRefs:
    - name: ${GATEWAY_NAME}
      sectionName: http
  rules:
    - filters:
        - type: RequestRedirect
          requestRedirect:
            scheme: https
            statusCode: 301
