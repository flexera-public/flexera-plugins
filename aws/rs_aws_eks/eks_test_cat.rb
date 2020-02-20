name 'EKS Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - EKS"
import "aws_eks"

parameter "region" do
  like $aws_eks.region
end

resource "my_cluster", type: "aws_eks.clusters" do
  name "my_kube_cluster"
  resources_vpc_config do {
    "securityGroupIds" => ["sg-7dad9003"],
    "subnetIds" => ["subnet-b357c2fb","subnet-bb06b7e1"],
    "vpcId" => "vpc-8172a6f8"
  } end
  role_arn "arn:aws:iam::041819229125:role/DF-EKS-Role"
  version "1.14"
end

output "out_endpoint" do
  label "EKS Endpoint"
  default_value @my_cluster.endpoint
end

output "out_version" do
  label "Kube Version"
  default_value @my_cluster.version
end