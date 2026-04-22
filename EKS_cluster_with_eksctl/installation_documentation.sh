------------------------------- Eks installation documentation -------------------------------

1) create a cluster using eksctl with the following command:

------------------- without node group -------------------
eksctl create cluster --name <cluster-name> --region <region> --without-nodegroup
------------------- with node group -------------------
eksctl create cluster --name <cluster-name> --region <region> --nodegroup-name <node-group-name> --node-type <instance-type> --nodes <number-of-nodes> 

------ node group example ------
create command in linux mode:
 eksctl create nodegroup --cluster=monitoring-eks \
    --region=us-east-1 \
    --name=monitoring-linux-group \
    --node-type=t3.large \
    --nodes-min=2 \
    --nodes-max=3 \
    --node-volume-size=80 \
    --managed \
    --node-private-networking

eksctl create nodegroup --cluster=monitoring-eks --region=us-east-1 --name=monitoring-linux-group --node-type=c7i-flex.large --nodes-min=2 --nodes-max=3 --node-volume-size=80  --managed --node-private-networking

2) verify the cluster and node group creation:
eksctl get cluster --name <cluster-name> --region <region>
eksctl get nodegroup --cluster <cluster-name> --region <region>

------------------------------- Delete cluster -------------------------------
eksctl delete cluster --name <cluster-name> --region <region>
