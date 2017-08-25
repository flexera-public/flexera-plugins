name 'rs_azure_dns'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure DNS Plugin"
long_description "Azure DNS Version: 2016-04-01"
package "plugins/rs_azure_dns"
import "sys_log"

parameter "subscriptionId" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_dns" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2016-04-01'
    } end
  end

  parameter "subscriptionId" do
    type  "string"
    label "subscriptionId"
  end

  type "zone" do
    href_templates "{{contains(id, 'dnszones') && id || null}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "location" do
      type "string"
      location "body"
      required true
    end

    field "resource_group" do
      type "string"
      location "path"
      required true
    end

    field "name" do
      type "string"
      location "path"
      required true
    end

    field "tags" do
      type "composite"
      location "body"
    end

    field "if_match" do
      type "string"
      location "header"
      alias_for "If-Match"
    end

    field "if_none_match" do
      type "string"
      location "header"
      alias_for "If-None-Match"
    end

    action "create" do
      type "zone"
      path "/subscriptions/$subscriptionId/resourceGroups/$resource_group/providers/Microsoft.Network/dnsZones/$name"
      verb "PUT"
    end

    action "show" do
      type "zone"
      path "/subscriptions/$subscriptionId/resourceGroups/$resource_group/providers/Microsoft.Network/dnsZones/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      field "name" do
        location "path"
      end
    end

    action "get" do
      type "zone"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "zone"
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","type","properties","etag"
  end

  type "record_set" do
    # This nasty jmespath is because zone and record_sets have similar hrefs with only distinguishing path argument being recordType. TODO: Perhaps we should match on number of '/'?
    href_templates "{{(\
contains(id, 'dnszones') && \
(contains(id, '/a/') || \
contains(id, '/soa/') || \
contains(id, '/aaaa/') || \
contains(id, '/mx/') || \
contains(id, '/ns/') || \
contains(id, '/ptr/') || \
contains(id, '/srv/') || \
contains(id, '/txt/') || \
contains(id, '/cname/') || \
contains(id, '/soa/'))\
) &&id || null}}"

    provision "provision_resource"
    delete    "delete_resource"

    field "properties" do
      type "object"
      location "body"
      required true
    end

    field "name" do
      type "string"
      location "path"
      required true
    end

    field "recordType" do
      type "string"
      location "path"
      required true
    end

    field "resource_group" do
      type "string"
      location "path"
      required true
    end

    field "zoneName" do
      type "string"
      location "path"
      required true
    end

    field "if_match" do
      type "string"
      location "header"
      alias_for "If-Match"
    end

    field "if_none_match" do
      type "string"
      location "header"
      alias_for "If-None-Match"
    end

    action "create" do
      type "zone"
      path "/subscriptions/$subscriptionId/resourceGroups/$resource_group/providers/Microsoft.Network/dnsZones/$zoneName/$recordType/$name"
      verb "PUT"
    end

    action "show" do
      type "zone"
      path "/subscriptions/$subscriptionId/resourceGroups/$resource_group/providers/Microsoft.Network/dnsZones/$zoneName/$recordType/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      field "name" do
        location "path"
      end

      field "zoneName" do
        location "path"
      end

      field "recordType" do
        location "path"
      end

    end

    action "get" do
      type "zone"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "zone"
      path "$href"
      verb "DELETE"
    end

    output "id","name","type","etag","properties"
  end
end

resource_pool "rs_azure_dns" do
    plugin $rs_azure_dns
    parameter_values do
      subscriptionId $subscriptionId
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/09b8fec1-4b8d-48dd-8afa-5c1a775ea0f2/oauth2/token"
      grant type: "client_credentials" do
        client_id cred("AZURE_APPLICATION_ID")
        client_secret cred("AZURE_APPLICATION_KEY")
        additional_params do {
          "resource" => "https://management.azure.com/"
        } end
      end
    end
end

define skip_known_error() do
  # If all errors were concurrent resource group errors, skip
  $_error_behavior = "skip"
  foreach $e in $_errors do
    call sys_log.detail($e)
    if $e["error_details"]["summary"] !~ /Concurrent process is creating resource group/
      $_error_behavior = "raise"
    end
  end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    call sys_log.detail(join(["fields", $fields]))
    $type = $object["type"]
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    rs_azure_dns.$type.create($fields)
    call stop_debugging()
    call start_debugging()

    if $type == "zone"
      @resource = rs_azure_dns.zone.show(resource_group: $resource_group, name: $name)
    else
      $zoneName = $fields["zoneName"]
      $recordType = $fields["recordType"]
      @resource = rs_azure_dns.record_set.show(resource_group: $resource_group, name: $name, zoneName: $zoneName, recordType: $recordType)
    end

    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  sub on_error: skip do
    @declaration.destroy()
  end
  call stop_debugging()
end

define stop_debugging_and_raise() do
  call stop_debugging()
  raise $_errors
end

define no_operation(@declaration) do
  $object = to_object(@declaration)
  call sys_log.detail("declaration:" + to_s($object))
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
