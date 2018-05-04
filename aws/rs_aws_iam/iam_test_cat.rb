name 'iam test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - IAM"
long_description "creates and destroys test IAM role and policy"
import "plugins/rs_aws_iam"


output "role_name" do
  label "IAM Role Name"
  default_value @my_role.RoleName
end

output "policy_name" do
  label "IAM Policy Name"
  default_value @my_policy.PolicyName
end

output "instance_profile_name" do
  label "IAM Policy Name"
  default_value @my_instance_profile.InstanceProfileName
end

resource "my_policy", type: "rs_aws_iam.policy" do
  name "MyTestPolicy"
  policy_document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:ListAllMyBuckets",
"Resource":"arn:aws:s3:::*"},{"Effect":"Allow","Action":["s3:Get*","s3:List*"],"Resource":
["arn:aws:s3:::EXAMPLE-BUCKET","arn:aws:s3:::EXAMPLE-BUCKET/*"]}]}'
  description "test policy description"
end

resource "my_policy2", type: "rs_aws_iam.policy" do
  name "MyTestPolicy2"
  policy_document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:ListAllMyBuckets",
"Resource":"arn:aws:s3:::*"},{"Effect":"Allow","Action":["s3:Get*","s3:List*"],"Resource":
["arn:aws:s3:::EXAMPLE-BUCKET2","arn:aws:s3:::EXAMPLE-BUCKET2/*"]}]}'
  description "test policy description"
end

resource "my_role", type: "rs_aws_iam.role" do
  name 'MyTestRole'
  assume_role_policy_document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["ec2.amazonaws.com"]},"Action":["sts:AssumeRole"]}]}'
  description "test role description"
  policies @my_policy.Arn, @my_policy2.Arn
end

resource "my_instance_profile", type:"rs_aws_iam.instance_profile" do
  name "MyInstanceProfile"
  role_name @my_role.RoleName
end

operation "terminate" do
  definition "terminate"
end

define terminate(@my_role) do
  delete(@my_role)
end
