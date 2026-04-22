-------------------- EKS External Secrets Store CSI Driver Installation --------------------

Store MSSQL credentials in AWS Secrets Manager
1. Create a secret in AWS Secrets Manager with the MSSQL credentials.

------------------------------- Create IAM Policy and Role for EKS to access AWS Secrets Manager -------------------------------
1) Create IAM Policy for EKS to read secret
     {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
---------------------------------------- Create IAM Role and Service Account for external secrets store controller-------------------------------

2) Create IAM role and attach the above policy to it, and also attach the role to EKS worker nodes.
3) eksctl create iamserviceaccount \
  --name external-secrets-sa \
  --namespace external-secrets \
  --cluster <your-cluster-name> \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/<policy-name> \
  --approve

eksctl create iamserviceaccount --name external-secrets-sa --namespace external-secrets --cluster <your-cluster-name> --attach-policy-arn arn:aws:iam::585881786610:policy/AWS_EKS_SECRETMANAGER_POLICY --approve

this will create a name space and service account for external secrets in EKS and attach the IAM policy to it and IAM role.
  ---------------------------- Install External Secrets Store CSI Driver in EKS ----------------------------

External secret store should be install at time , Not required install in every namespace because it is cluster level resource and it can be used in any namespace by referencing the secret store name and namespace in the ExternalSecret resource.

1) Add the Helm repository for the External Secrets Store CSI Driver:
   helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
   helm repo update

2) Install the External Secrets Store CSI Driver using Helm:
   helm install external-secrets external-secrets/external-secrets \
  -n <namespace> \
  --create-namespace \
  --set serviceAccount.name=external-secrets-sa \
  --set serviceAccount.create=false
   
helm install external-secrets external-secrets/external-secrets -n external-secrets  --set serviceAccount.name=external-secrets-sa --set serviceAccount.create=false

3) Verify the installation:
   kubectl get pods -n external-secrets

-------------------------------- cluster level secret store --------------------------------
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: aws-secret-store
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
            namespace: external-secrets

verify the cluster secret store:
kubectl get clustersecretstore aws-secret-store -o yaml

----------------------------------------------- Create ClusterExternalSecret to sync secret from AWS Secrets Manager to Kubernetes at cluster level --------------------------------

apiVersion: external-secrets.io/v1
kind: ClusterExternalSecret
metadata:
  name: mssql-global   # Name of the ClusterExternalSecret
spec:
  externalSecretName: mssql-secret  # Name of the Kubernetes Secret to be created
  refreshTime: 1m
  namespaceSelector:
    matchLabels:
      app: expense-tracker
      environment: dev  # change label selector to match the namespaces where you want this secret to be available
  externalSecretSpec:
    refreshInterval: 1h
    secretStoreRef:
      name: aws-secret-store  # Reference to the ClusterSecretStore defined earlier
      kind: ClusterSecretStore
    target:
      name: mssql-secret  # Kubernetes Secret name
      creationPolicy: Owner   # The secret will be deleted when the ClusterExternalSecret is deleted
    data:
      - secretKey: SQL_username
        remoteRef:
          key: dev/mssql/credentials
          property: username
      - secretKey: SQL_password
        remoteRef:
          key: dev/mssql/credentials
          property: password  
      - secretKey: SQL_database
        remoteRef:  
          key: dev/mssql/credentials
          property: database  
  
Verify the ClusterExternalSecret creation:
kubectl get clusterexternalsecret mssql-global -o yaml
