name 'Plugin: AzureRM Resource'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure - ARM Resource"
long_description "Version: 1.0"
package "plugins/rs_azure_resource"
import "sys_log"

parameter "subscription_id" do
  type "string"
  label "Subscription ID"
end

plugin "rs_azure_resource" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
  end

  parameter "subscription_id" do
    type "string"
    label "subscription_id"
  end

  type "resource" do
    href_templates "{{type(id)=='string' && id || null}}","{{type(value)=='array' && value[].id || null}}"
    provision "no_operation"
    delete "no_operation"

    field "api_version" do
      type "string"
      location "query"
      alias_for "api-version"
    end

    field "properties" do
      type "composite"
      location "body"
    end

    field "tags" do
      type "composite"
      location "body"
    end

    field "resource_group" do
      type "string"
      location "path"
    end

    field "resource_provider_namespace" do
      type "string"
      location "path"
    end

    field "parent_resource_path" do
      type "string"
      location "path"
    end

    field "resource_type" do
      type "string"
      location "path"
    end

    field "name" do
      type "string"
      location "path"
    end

    action "update" do
      path "$href"
      verb "PUT"

      field "api_version" do
        location "query"
        alias_for "api-version"
      end
    end

    action "updatebyid" do
      path "$href"
      verb "PATCH"

      field "api_version" do
        location "query"
        alias_for "api-version"
      end
    end 

    action "get" do
      path "$href"
      verb "GET"
    end

    action "list" do
      path "/subscriptions/$subscription_id/resources"
      verb "GET"

      output_path "value[*]"
    end

    action "listbyresourcegroup" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/resources"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      output_path "value[*]"
    end

    output "id","location","name","tags","type","properties","identity","kind","managedBy","plan","sku"
  end
end

resource_pool "rs_azure_resource" do
    plugin $rs_azure_resource
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

define delete_resource(@declaration) do
  call start_debugging()
  @declaration.destroy()
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

