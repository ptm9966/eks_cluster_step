-------------------------------- create oid provider for EKS cluster --------------------------------
To create an OIDC provider for your EKS cluster, you can use the AWS CLI to


  eksctl utils associate-iam-oidc-provider --region <REGION> --cluster <CLUSTER_NAME> --approve

Replace <REGION> and <CLUSTER_NAME> with your actual values.
This command will associate the OIDC provider with your EKS cluster and create the necessary IAM resources.

---------------------------------- Create IAM Role and Service Account for EBS CSI Driver --------------------------------

eksctl create iamserviceaccount --region us-east-1  --name ebs-csi-controller-sa --namespace kube-system --cluster observability --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --override-existing-serviceaccounts

this command creatre 
1) IAM role and  attach the AmazonEBSCSIDriverPolicy to it with odic provider 
   role name: eksctl-eks-cluseter-

2) create a name space 
3) create a service account and attach the IAM role to it 
   service account name: ebs-csi-controller-sa
   namespace: kube-system
------------------------------- Install EBS CSI Driver using Helm ----------------------------

1) Add the Helm repository for the EBS CSI Driver:
    helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    helm repo update
2) Install the EBS CSI Driver using Helm:
   helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver -n kube-system --set controller.serviceAccount.name=ebs-csi-controller-sa --set controller.serviceAccount.create=false

verify the installation:
   kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver