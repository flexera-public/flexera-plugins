name 'rs_azure_cosmosdb'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure CosmosDB Plugin"
long_description "Version: 1.0"
package "plugins/rs_azure_cosmosdb"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_cosmosdb" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2015-04-08'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "db_account" do
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

    action "create" do
      type "db_account"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DocumentDB/databaseAccounts/$name"
      verb "PUT"
    end

    action "show" do
      type "db_account"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DocumentDB/databaseAccounts/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end 

      field "name" do
        location "path"
      end
    end

    action "get" do
      type "db_account"
      path "$href"
      verb "GET"
    end

    action "update" do
      type "db_account"
      path "$href"
      verb "PUT"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","properties","type","kind"

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "state" do
      body_path "properties.provisioningState"
    end

    output "ipRangeFilter" do
      body_path "properties.ipRangeFilter"
    end

    output "isVirtualNetworkFilterEnabled" do
      body_path "properties.isVirtualNetworkFilterEnabled"
    end 

    output "databaseAccountOfferType" do
      body_path "properties.databaseAccountOfferType"
    end 

    output "consistencyPolicy" do
      body_path "properties.consistencyPolicy"
    end 

    output "writeLocations" do
      body_path "properties.writeLocations"
    end 

    output "readLocations" do
      body_path "properties.readLocations"
    end 

    output "failoverPolicies" do
      body_path "properties.failoverPolicies"
    end

    output "virtualNetworkRules" do
      body_path "properties.virtualNetworkRules"
    end 
  end
end

resource_pool "rs_azure_cosmosdb" do
    plugin $rs_azure_cosmosdb
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
    $type = $object["type"]
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_cosmosdb.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @new_resource = @operation.get()
    $status = @new_resource.state
    while $status != "Succeeded" do
      $status = @new_resource.state
      if $status == "Failed"
        call stop_debugging()
        raise "Execution Name: "+ $name + ", Status: " + $status
      end
      call stop_debugging()
      call sys_log.detail(join(["Status: ", $status]))
      call start_debugging()
      sleep(10)
    end
    @resource = @new_resource
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define handle_retries($attempts) do
  if $attempts <= 6
    sleep(10*to_n($attempts))
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do 
    $delete_count = $delete_count + 1
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