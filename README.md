eksctl create cluster --name digital-eks --region us-east-1 --without-nodegroup

eksctl create nodegroup --cluster digital-eks --name my-private-nodes --region us-east-1 --node-type c7i-flex.large --nodes 2 --nodes-min 2 --nodes-max 2 --node-private-networking --managed
#############################################################
eksctl utils associate-iam-oidc-provider \
  --cluster my-eks-cluster \
  --region us-west-2 \
  --approve

eksctl utils associate-iam-oidc-provider --cluster digital-eks --region us-east-1 --approve

###################################################################################################################################
AmazonEBSCSIDriverPolicy

ebs-csi-controller-sa

ebs-csi-controller-sa


eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster digital-eks --attach-policy-arn arn:aws:iam::585881786610:policy/AmazonEBSCSIDriverPolicyV2 --approve --override-existing-serviceaccounts

eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster demo-eks --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --override-existing-serviceaccounts

helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system --set controller.serviceAccount.create=false --set controller.serviceAccount.name=ebs-csi-controller-sa

#################################################################################

# Replace placeholders
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=<your-vpc-id>


# Replace placeholders
eksctl create iamserviceaccount --cluster demo-eks --namespace kube-system --name aws-load-balancer-controller --attach-policy-arn arn:aws:iam::585881786610:policy/AWSLoadBalancerControllerIAMPolicy --approve

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller-sa \
  --set vpcId=<your-vpc-id>

helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=demo-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --namespace kube-system --set vpcId=vpc-0d7152585a507a159

###########################################################################################################

eksctl create iamserviceaccount \
  --name mssql-sa \
  --namespace default \
  --cluster my-eks-cluster \
  --attach-policy-arn arn:aws:iam::ACCOUNT_ID:policy/mssql-secrets-policy \
  --approve \
  --override-existing-serviceaccounts

eksctl create iamserviceaccount --name mssql-sa --namespace default --cluster demo-eks --attach-policy-arn arn:aws:iam::585881786610:policy/AWS_EKS_SECRETMANAGER_POLICY --approve --override-existing-serviceaccounts

