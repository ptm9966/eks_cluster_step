--------------------------------------------AWS Load Balancer Controller Installation Guide--------------------------

Step 1: Get Cluster OIDC Provider
To create an IAM role for the AWS Load Balancer Controller, you need to get the OIDC provider URL for your EKS cluster. You can do this using the AWS CLI with the following command, replacing <CLUSTER_NAME> and <REGION> with your actual values:

aws eks describe-cluster --name <CLUSTER_NAME> --region <REGION> --query "cluster.identity.oidc.issuer" --output text

Create OIDC Provider (if not exists)

--------------------------------------------------------Create IAM Policy---------------------------------------------
Step 2: Create IAM Policy

Create a file named iam_policy.json and add the following content to it:
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

Policy Name: AWSLoadBalancerControllerIAMPolicy

Then, create the IAM policy using the AWS CLI:
------------------------------------- eksctl command to creat service account with iam policy -------------------------------------
eksctl create iamserviceaccount --cluster demo-eks \
 --namespace kube-system \
 --name <service-account-name> \ 
 --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/<POLICY_NAME> \ 
 --approve

 This command creates
 1) IAM role and attach the AWSLoadBalancerControllerIAMPolicy to it with odic provider 
    role name: eksctl-eks-cluseter-demo-eks-addon-iamserviceaccount-kube-system-aws-load-balancer-controller
2) create a name space if not exists
3) create a service account and attach the IAM role to it
   service account name: aws-load-balancer-controller

eg : eksctl create iamserviceaccount --cluster demo-eks --namespace kube-system --name aws-load-balancer-controller --attach-policy-arn arn:aws:iam::585881786610:policy/AWSLoadBalancerControllerIAMPolicy --approve

----------------------------------------------------------Create IAM Role---------------------------------------------
Step 3: Create IAM Role (IRSA)
Create an IAM role for the AWS Load Balancer Controller and attach the policy you created in the previous step. You can use the following command, replacing <ACCOUNT_ID> and <CLUSTER_NAME> with your actual values:
Name: AmazonEKSLoadBalancerControllerRole 
Policy: AWSLoadBalancerControllerIAMPolicy
system:serviceaccount:kube-system:aws-load-balancer-controller
- ---------------------------------------Create Kubernetes Service Account---------------------------------------------
Step 4: Create Kubernetes Service Account
Create a Kubernetes service account for the AWS Load Balancer Controller and annotate it with the IAM role
kubectl apply -f service_account.yml

------------------------------------------------Step 5: Install AWS Load Balancer Controller using Helm-----------------
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set region=ap-south-1 \
  --set vpcId=<your-vpc-id> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
# Make sure to replace <cluster-name> and <your-vpc-id> with your actual cluster name and VPC ID.
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=demo-eks --set region=us-east-1 --set vpcId=vpc-06efd76daaa4fa1d5  --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

----------------------------------------------Verify Installation---------------------------------------------
To verify that the AWS Load Balancer Controller is installed and running correctly, you can check the status of the controller's deployment and pods:

kubectl get deployment aws-load-balancer-controller -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

If the deployment and pods are running without any issues, it indicates that the AWS Load Balancer Controller has been successfully installed in your EKS cluster. You can now proceed to create and manage load balancers for your applications using the AWS Load Balancer Controller.
