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
---------------------------------------- Create IAM Role and Service Account for EKS -------------------------------

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

------------------------------ create service account in namespace ------------------------------
1) create service account in the namespace where you want to use the secret store and attach the same IAM role to it that you created for the external secrets service account in the previous step.

eksctl create iamserviceaccount \
  --name <service-account-name> \ # namespace service account name
  --namespace <namespace> \ # namespace where you want to use the secret store
  --cluster <your-cluster-name> \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/<policy-name> \
  --approve

Ex: eksctl create iamserviceaccount --name epnesstracker-secrets-sa --namespace epness-tracker --cluster demo-eks --attach-policy-arn arn:aws:iam::585881786610:policy/AWS_EKS_SECRETMANAGER_POLICY --approve
------------------------------- namespace level SecretStore (connect EKS → AWS)-----------------------------
1) Create a SecretStore resource that defines how to connect to AWS Secrets Manager. This resource will specify the provider (AWS), the region, and the authentication method (using the IAM role attached to the EKS worker nodes).
 
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: expenesstracker-secret-store  # change name 
  namespace: expeness-tracker  # change namespace
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1   # change region
      auth:
        jwt:
          serviceAccountRef:
            name: expenesstracker-secrets-sa  # change service account name

Verfy the SecretStore creation:
kubectl get secretstore -n expeness-tracker

---------------------------------------- namespace level ExternalSecret (fetch secret from AWS and create k8s secret) --------------------------------------
1) Create an ExternalSecret resource that references the SecretStore and specifies which secret to fetch from AWS Secrets Manager and how to map it to a Kubernetes Secret.

apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: mssql-secret
  namespace: expeness-tracker
spec:
  refreshInterval: 1h  # how often to refresh the secret from AWS Secrets Manager
  secretStoreRef:
    name: expenesstracker-secret-store # reference to the SecretStore created in the previous step
    kind: SecretStore
  target:
    name: mssql-secret   # Kubernetes Secret name
    creationPolicy: Owner # This means the Kubernetes Secret will be created and managed by the ExternalSecret controller. If the ExternalSecret is deleted, the Kubernetes Secret will also be deleted.
  data:
    - secretKey: username
      remoteRef:
        key: dev/mssql/credentials
        property: username

    - secretKey: sa_password
      remoteRef:
        key: dev/mssql/credentials
        property: password

    - secretKey: database
      remoteRef:
        key: dev/mssql/credentials
        property: database