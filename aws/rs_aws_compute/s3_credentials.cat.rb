name 'AWS S3 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"

credentials "auth_s3" do
  schemes "aws","aws_sts"
  label "AWS"
  description "Select the AWS Credential from the list"
  tags "provider=aws"
end

operation "launch" do
  definition "generated_launch"
end

define generated_launch($auth_s3) return $file do
  $file = http_get({
    url: "https://s3.amazonaws.com/1-rs-policy-list/5f4e5f5f63ba400001f1b095.json",
    auth: $auth_s3
  })
end
