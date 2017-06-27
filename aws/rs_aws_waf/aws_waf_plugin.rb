name 'aws_waf_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Web Application Firewall"
package "plugins/rs_aws_waf"
import "sys_log"

plugin "rs_aws_waf" do
  endpoint do
    default_scheme "https"
    default_host "waf.amazonaws.com"
    path "/"
    headers do {
      "Content-Type": "application/x-amz-json-1.1"
    } end
  end
  
  # http://docs.aws.amazon.com/efs/latest/ug/api-reference.html
  type "web_acl" do
    href_templates "{{WebACL.WebACLId}}"

    field "change_token" do
      alias_for "ChangeToken"
      type "string"
      #required true
    end

    field "default_action" do
      alias_for "DefaultAction"
      type "object"
    end 

    field "metric_name" do
      alias_for "MetricName"
      type "string"
      required true
    end

    field "name" do
      alias_for "Name"
      type "string"
      required true
    end 

    # Non-create fields
    field "id" do
      alias_for "WebACLId"
      type "string"
    end

    action "show" do
      verb "GET"

      field "id"
        alias_for "WebACLId"
      end
    end

    action "create" do
      verb "POST"


end

resource_pool "waf" do
  plugin $rs_aws_waf
  auth "key", type: "aws" do
    version     4
    service    'elasticfilesystem'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

