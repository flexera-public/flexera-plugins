name 'rs_azure_compute'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Compute Plugin"
long_description "Version: 1.0"
package "plugins/rs_azure_compute"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_compute" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2016-04-30-preview'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "availability_set" do
    href_templates "{{id}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "location" do
      type "string"
      location "body"
    end

    field "resource_group" do
      type "string"
      location "path"
    end 

    field "name" do
      type "string"
      location "path"
    end
    
    field "tags" do
      type "composite"
      location "body"
    end

    field "sku" do
      type "composite"
      location "body"
    end

    action "create" do
      type "availability_set"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Compute/availabilitySets/$name"
      verb "PUT"
    end

    action "show" do
      type "availability_set"
      path "$href"
      verb "GET"
    end

    action "show_ro" do
      type "availability_set"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Compute/availabilitySets/$name"
      verb "GET"
    end

    action "get" do
      type "availability_set"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "availability_set"
      path "$href"
      verb "DELETE"
    end
    
    output "virtualmachines" do
      body_path "properties.virtualmachines"
    end

    output "id","name","location","tags","sku","properties"
  end

  type "virtualmachine" do
    href_templates "{{contains(id, 'virtualMachines') && id || null}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "location" do
      type "string"
      location "body"
    end

    field "resource_group" do
      type "string"
      location "path"
    end

    action "show" do
      type "availability_set"
      path "$href"
      verb "GET"
    end

    action "get" do
      type "availability_set"
      path "$href"
      verb "GET"
    end

    output "id","name","location","tags","properties"
  end
end

resource_pool "rs_azure_compute" do
    plugin $rs_azure_compute
    parameter_values do
      subscription_id $subscription_id
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
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_compute.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  sub on_error: skip do
    @declaration.destroy()
  end
  call stop_debugging()
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