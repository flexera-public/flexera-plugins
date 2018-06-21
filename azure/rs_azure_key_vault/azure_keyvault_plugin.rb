name 'rs_azure_keyvault'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Key Vault Plugin"
long_description "Version: 1.1"
package "plugins/rs_azure_keyvault"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_keyvault" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2016-10-01'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "vaults" do
    href_templates "{{type(id)=='string' && id || null}}","{{type(value)=='array' && value[].id || null}}"
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

    field "tags" do
      type "composite"
      location "body"
    end

    action "create" do
      type "vaults"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.KeyVault/vaults/$name"
      verb "PUT"
    end

    action "show" do
      type "vaults"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.KeyVault/vaults/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end 

      field "name" do
        location "path"
      end
    end

    action "listbyresourcegroup" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.KeyVault/vaults"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      output_path "value[*]"
    end

    action "get" do
      type "vaults"
      path "$href"
      verb "GET"
    end

    action "update" do
      type "vaults"
      path "$href"
      verb "PUT"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","properties","type"

    output "access_policies" do
      body_path "properties.accessPolicies"
    end

    output "create_mode" do
      body_path "properties.createMode"
    end

    output "enable_soft_delete" do
      body_path "properties.enableSoftDelete"
    end 

    output "enabled_for_deployment" do
      body_path "properties.enabledForDeployment"
    end 

    output "enabled_for_disk_encryption" do
      body_path "properties.enabledForDiskEncryption"
    end 

    output "enabled_for_template_deployment" do
      body_path "properties.enabledForTemplateDeployment"
    end 

    output "sku" do
      body_path "properties.sku"
    end 

    output "vault_uri" do
      body_path "properties.vaultUri"
    end 
  end
end

resource_pool "rs_azure_keyvault" do
    plugin $rs_azure_keyvault
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
    @operation = rs_azure_keyvault.$type.create($fields)
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    sub on_error: retry, timeout: 10m do
      call sys_log.detail("sleeping 10")
      sleep(10)
      @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    end
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    call sys_log.detail(to_object(@operation))
    @resource = @new_resource.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
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