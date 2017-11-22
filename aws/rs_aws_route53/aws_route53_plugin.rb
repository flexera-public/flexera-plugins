name 'aws_route53_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services  - Route53 Plugin"
long_description "Version: 1.0"
package "plugins/rs_aws_route53"
import "sys_log"

plugin "rs_aws_route53" do
  endpoint do
    default_scheme "https"
    path "/2013-04-01"
    request_content_type "application/xml"
  end
  
  type "hosted_zone" do
    href_templates "/hostedzone/{{//CreateHostedZoneResponse/HostedZone/Id}}", "/hostedzone/{{//GetHostedZoneResponse/HostedZone/Id}}"

    field "caller_reference" do
      alias_for "CallerReference"
      type "string"
      required "true"
      location "body"
    end

    field "name" do
      alias_for "Name"
      type "string"
      required true
      location "body"
    end
 
    output "Id"

    action "create" do
      verb "POST"
      path "/2013-04-01/hostedzone"
      output_path "//CreateHostedZoneResponse/HostedZone"
    end

    action "destroy" do
      verb "DELETE"
      path "/hostedzone/$Id"
    end
    
    action "get" do
      verb "GET"
      path "/hostedzone/$Id"
      output_path "//GetHostedZoneResponse/HostedZone"
    end
  end
end

resource_pool "route53" do
  plugin $rs_aws_route53
  host "route53.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'route53'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $existing_fields = $object["fields"]
    $tags = $fields["tags"]
    $type = $object["type"]
    $fields = ["CreateHostedZoneRequest"]
    $fields["CreateHostedZoneRequest"] = $existing_fields
    @operation = rs_aws_route53.$type.create($fields)
    @resource = @operation.get()
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  call stop_debugging()
end

define start_debugging()
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end

resource "hostedzone", type: "rs_aws_route53.hosted_zone" do
  name "example.com"
  caller_reference to_s(uuid())
end
