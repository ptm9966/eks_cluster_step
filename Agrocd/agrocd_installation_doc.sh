-------------------------------------- agrocd installation doc --------------------------------------
1) Create a namespace for Argo CD:
   kubectl create namespace argocd

-------------------------------- Install Argo CD using Helm --------------------------------------
1) Add the Helm repository for Argo CD:
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
2) Install Argo CD using Helm:
   helm install argocd argo/argo-cd -n argocd

---------------------------------- Verify the installation --------------------------------------
1) Check the status of the Argo CD pods:
   kubectl get pods -n argocd
2) Access the Argo CD UI:
   kubectl port-forward svc/argocd-server -n argocd 8080:80
   Open your browser and navigate to http://localhost:8080
3) Get the initial admin password:
   kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode    
    The username is "admin" and the password is the value retrieved from the above command.

--------------------------------- update to load balancer --------------------------------------
1) Update the Argo CD server service to use a LoadBalancer:
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
2) Get the external IP address of the LoadBalancer:
    kubectl get svc argocd-server -n argocd
3) Access the Argo CD UI using the external IP address:
    Open your browser and navigate to http://<external-ip>:80

----------------------------------- Uninstall Argo CD --------------------------------------
1) Uninstall Argo CD using Helm:
    helm uninstall argocd -n argocd
2) Delete the Argo CD namespace:
    kubectl delete namespace argocd

-------------------------------------- change values.yml file --------------------------------------
To customize the values.yml file for Argo CD, you can follow these steps:
1. Create a custom values.yml file: You can create a new file named custom_values.yml and add your desired configurations for Argo CD.
server:
  service:
    type: LoadBalancer
  extraArgs:
    - --insecure
    - --rootpath=/argocd
    - --dex-server=http://dex-server:5556
repositoryCredentials:
  - url:  

---------------------------------- application loadbalancer ingress for agrocd --------------------------------------
1) Create an Ingress resource for Argo CD server:
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
spec:
    rules:
    - http: 
        paths:  
