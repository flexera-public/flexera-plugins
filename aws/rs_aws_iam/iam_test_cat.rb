name 'iam test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - IAM"
import "plugins/rs_aws_iam"


output "role_name" do
  label "IAM Role Name"
  default_value @my_role.RoleName
end

resource "my_role", type: "rs_aws_iam.role" do
  name 'MyTestRole'
  assume_role_policy_document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow",
        "Principal":{"Service":["ec2.amazonaws.com"]},"Action":["sts:AssumeRole"]}]}'
  description "test role description"
  max_session_duration 3600
end
