name 'EKS Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - EMR"
import "plugins/rs_aws_emr"


resource "my_cluster", type: "rs_aws_emr.clusters" do
  name "my_emr_cluster"
  resources_vpc_config do {
    "securityGroupIds" => ["sg-7dad9003"],
    "subnetIds" => ["subnet-b357c2fb","subnet-bb06b7e1"],
    "vpcId" => "vpc-8172a6f8"
  } end
  role_arn "arn:aws:iam::041819229125:role/DF-EKS-Role"
  version "1.10"
end

output "out_endpoint" do
  label "EKS Endpoint"
  default_value @my_cluster.endpoint
end

output "out_version" do
  label "Kube Version"
  default_value @my_cluster.version
end