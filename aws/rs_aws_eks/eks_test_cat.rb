name 'EKS Cluster'
rs_ca_ver 20161221
short_description "![eks](https://s3.amazonaws.com/rs-pft-logos/eks.png)

Provision an AWS EKS Cluster"

import "plugins/rs_aws_eks"
import "plugins/rs_aws_iam"

parameter "param_iam_role" do
  label "IAM Role ARN"
  description "NOTE: Leave blank to create a new IAM Role"
  type "string"
  default " "
  category "Deployment Options"
end

parameter "param_kube_version" do
  label "Kube Version"
  type "string"
  default "1.10"
  category "Deployment Options"
end

parameter "param_use1b" do
  label "us-east-1b"
  type "string"
  allowed_values "true","false"
  category "Deployment Options"
end

parameter "param_use1c" do
  label "us-east-1c"
  type "string"
  allowed_values "true","false"
  category "Deployment Options"
end

parameter "param_use1d" do
  label "us-east-1d"
  type "string"
  allowed_values "true","false"
  category "Deployment Options"
end

output "out_endpoint" do
  label "EKS Endpoint"
  default_value @eks_cluster.endpoint
end

output "out_version" do
  label "Kube Version"
  default_value @eks_cluster.version
end

resource "eks_iam_role", type: "rs_aws_iam.role" do
  name join(["eks_role_", last(split(@@deployment.href, "/"))])
  assume_role_policy_document '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "eks.amazonaws.com"},"Action": "sts:AssumeRole"}]}'
  description "IAM role created for EKS via RightScale CAT"
  policies ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy","arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]
end

resource "eks_cluster", type: "rs_aws_eks.clusters" do
  name join(["my_kube_cluster_", last(split(@@deployment.href, "/"))])
  resources_vpc_config do {
    "securityGroupIds" => ["sg-9d5a0ae2"],
    "subnetIds" => [],
    "vpcId" => "vpc-7a64641c"
  } end
  role_arn @eks_iam_role.Arn
  version $param_kube_version
end

operation "launch" do
  definition "launch"
end

define launch(@eks_iam_role, @eks_cluster, $param_iam_role, $param_use1b, $param_use1c, $param_use1d) return @eks_iam_role, @eks_cluster do

  if $param_iam_role == " "
    provision(@eks_iam_role)
  else
    $eks_hash = to_object(@eks_cluster)
    $eks_hash["fields"]["role_arn"] = $param_iam_role
    @eks_cluster = $eks_hash
  end

  $subnets = []
  if $param_use1b == "true"
    $subnets << "subnet-643eda48"
  end
  if $param_use1c == "true"
    $subnets << "subnet-d7d80e9f"
  end
  if $param_use1d == "true"
    $subnets << "subnet-95697bce"
  end

  $eks_hash = to_object(@eks_cluster)
  $eks_hash["fields"]["resources_vpc_config"]["subnetIds"] = $subnets
  @eks_cluster = $eks_hash

  provision(@eks_cluster)
end

