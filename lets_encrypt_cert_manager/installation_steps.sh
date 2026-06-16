################################## Installation Steps ##############################
The standard way to use Let’s Encrypt on Kubernetes is through cert-manager, which automates certificate issuance and renewal.

############################## Install Cert-manager #####################3
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.15.0 \
  --set crds.enabled=true
---- Verify ------
kubectl get pods -n cert-manager

################################ Create a ClusterIssuer (Let’s Encrypt) one-time installation in cluster level ##############

Let’s Encrypt provides certificates in two environments:

Staging (testing)
Production (real certificates)

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: your-email@example.com    # chnage your email
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    - http01:
        ingress:
          class: nginx

------------------ verify ---------------
kubectl get clusterissuer
If READY is missing or not True, it’s not working yet.

kubectl describe clusterissuer letsencrypt-prod
❌ Common failure signs
DNS / network issues
Failed to register ACME account
dial tcp: i/o timeout
Email / ACME misconfig
invalid contact email
Solver issues

##########################################  Annotations and tls block in ingress ######################33

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - demo.example.com
    secretName: demo-tls   # this certificate by ingress not required to manually creation
  rules:
  - host: demo.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo-service
            port:
              number: 80

------------------ verify----------------

kubectl get certificate
kubectl describe certificate demo-tls
kubectl get secret demo-tls

Common issues (quick fixes)
❌ Challenge fails
DNS not pointing to ingress IP
Firewall blocking port 80
❌ Pending certificate
Check:
kubectl describe order
kubectl describe challenge

   
