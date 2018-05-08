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
    href_templates "$Id","{{Id}}","{{//CreateHostedZoneResponse/HostedZone/Id}}", "{{//GetHostedZoneResponse/HostedZone/Id}}"
    provision "provision_resource"
    delete "delete_resource"
    
    field "create_hosted_zone_request" do
      alias_for "CreateHostedZoneRequest"
      type "composite"
      required true
      location "body"
    end

    output "Id","Name"

    action "create" do
      verb "POST"
      path "/hostedzone"
      output_path "//CreateHostedZoneResponse/HostedZone"
    end

    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    action "get" do
      verb "GET"
      path "$href"
      output_path "//GetHostedZoneResponse/HostedZone"
    end
  end

  type "resource_recordset" do
    href_templates "{{//ChangeInfo/Id}}", "{{//ChangeInfo/Id}}"
    provision "provision_resource_recordset"
    delete "delete_resource_recordset"

    field "hosted_zone_id" do
      type "string"
      location "path"
      required true
    end

    field "record_sets" do
      type "composite"
      required true
      location 'header'
    end

    field 'action' do
      type "string"
      required false
      location 'header'
    end

    field 'comment' do
      type "string"
      required false
      location 'header'
    end

    output "Id", "Status","Comment","SubmittedAt"

    action "create" do
      verb "POST"
      path "$hosted_zone_id/rrset/"
    end

    action "remove" do
      verb "POST"
      path "$hosted_zone_id/rrset/"

      # this field contains all the ChangeResourceRecordSetsRequest
      # document to be sent.  See Limitation in the Readme
      field "hosted_zone_id" do
        location "path"
      end
      field "ChangeResourceRecordSetsRequest" do
        alias_for "ChangeResourceRecordSetsRequest"
        location "body"
      end
    end

    action "get" do
      verb "GET"
      path "change/$Id"
      output_path "//ChangeInfo"
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
    $object = to_object(@declaration)
    call sys_log.detail("object:"+ to_s($object))
    $fields = $object["fields"]
    call sys_log.detail("existing_fields:" + to_s($fields))
    $type = $object["type"]
    call sys_log.detail("fields:" + to_s($fields))
    call start_debugging()
    @operation = rs_aws_route53.$type.create($fields)
    @resource = @operation.get()
    call stop_debugging()
  end
end

define delete_resource(@resource) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @resource.destroy()
    call stop_debugging()
  end
end

define provision_resource_recordset(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $change_resource_record_sets_request =  {
        "xmlns": "https://route53.amazonaws.com/doc/2013-04-01/",
        "ChangeBatch": [{
          "Changes": [{
            "Change": [{
              "Action": [upcase($object['fields']['action'])],
              "ResourceRecordSet": [ $object['fields']['record_sets'] ]
            }]
          }],
          "Comment": [$object['fields']['comment']]
        }]
    }
    $fields['ChangeResourceRecordSetsRequest']=$change_resource_record_sets_request

    call start_debugging()
    @operation = rs_aws_route53.resource_recordset.create($fields)
    @resource = @operation.get()
    call stop_debugging()
  end
end

# this is a noop definition, but required by the resource_recordset delete field.
define delete_resource_recordset(@declaration) do
  #
end

define start_debugging() do
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
