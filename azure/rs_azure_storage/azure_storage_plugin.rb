name 'rs_azure_storage'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Storage Plugin"
long_description "Version: 1.1"
package "plugins/rs_azure_storage"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_storage" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2017-06-01'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "storage_account" do
    href_templates "{{id}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "resource_group" do
      type "string"
      location "path"
    end 

    field "name" do
      type "string"
      location "path"
    end

    field "properties" do
      type "composite"
      location "body"
    end

    field "location" do
      type "string"
      location "body"
    end

    field "kind" do
      type "string"
      location "body"
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
      type "storage_account"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Storage/storageAccounts/$name"
      verb "PUT"
    end

    action "update" do
      type "storage_account"
      path "$href"
      verb "PATCH"
    end

    action "list_keys" do
      path "$id/listKeys"
      verb "POST"
    end

    action "show" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Storage/storageAccounts/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end 

      field "name" do
        location "path"
      end
    end

    action "get" do
      type "storage_account"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "storage_account"
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","properties"

    output "state" do
      body_path "properties.provisioningState"
    end

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "primaryEndpoints" do
      body_path "properties.primaryEndpoints"
    end

    output "primaryLocation" do
      body_path "properties.primaryLocation"
    end

    output "statusOfPrimary" do
      body_path "properties.statusOfPrimary"
    end

    output "lastGeoFailoverTime" do
      body_path "properties.lastGeoFailoverTime"
    end

    output "secondaryLocation" do
      body_path "properties.secondaryLocation"
    end

    output "statusOfSecondary" do
      body_path "properties.statusOfSecondary"
    end

    output "creationTime" do
      body_path "properties.creationTime"
    end

    output "customDomain" do
      body_path "properties.customDomain"
    end

    output "secondaryEndpoints" do
      body_path "properties.secondaryEndpoints"
    end

    output "encryption" do
      body_path "properties.encryption"
    end

    output "accessTier" do
      body_path "properties.accessTier"
    end

    output "supportsHttpsTrafficOnly" do
      body_path "properties.supportsHttpsTrafficOnly"
    end
  end
end

resource_pool "rs_azure_storage" do
    plugin $rs_azure_storage
    parameter_values do
      subscription_id $subscription_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"
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
    @operation = rs_azure_storage.$type.create($fields)
    call stop_debugging()
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.detail("entering check for storage_account created")
    sub on_error: retry, timeout: 60m do
      call sys_log.detail("sleeping 10")
      sleep(10)
      call start_debugging()
      @new_resource = @operation.show(name: $name, resource_group: $resource_group )
      call stop_debugging()
    end
    call sys_log.detail("Checking that storage_account state is online")
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    $status = @new_resource.state
    sub on_error: skip, timeout: 60m do
      while $status != "Succeeded" do
        $status = @operation.show(name: $name, resource_group: $resource_group).state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        call start_debugging()
        sleep(10)
      end
    end
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    @resource = @new_resource
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