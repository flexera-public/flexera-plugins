name "Plugin: Azure Template"
# Version: 1.3
type 'plugin'
rs_ca_ver 20161221
short_description "Azure - ARM Template"
long_description "Version: 1.2"
package "plugins/azure_template"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

parameter "tenant_id" do
  type  "string"
  label "Tenant ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "azure_template" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      "api-version" => "2018-05-01"
    } end
  end

  parameter "subscription_id" do
    type      "string"
    label "subscription_id"
  end

  parameter "tenant_id" do
    type  "string"
    label "tenant_id"
  end

  type "subscription_deployment" do
    #href_templates "{{id}}"
    href_templates "{{(type(id)=='string' && !contains(id, '/resourceGroups/')) && id || null}}","{{(type(value)=='array' && !contains(value[0].id, '/resourceGroups/')) && value[].id || null}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
      required true
    end

    field "name" do
      type "string"
      location "path"
      required true
    end

    field "location" do
      type "string"
      location "body"
    end

    action "create" do
      path "/subscriptions/$subscription_id/providers/Microsoft.Resources/deployments/$name"
      verb "PUT"
    end

    action "get" do
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    action "update" do
      path "$href"
      verb "PUT"

      field "properties" do
        location "body"
      end
    end

    action "validate_template" do
      path "/subscriptions/$subscription_id/providers/Microsoft.Resources/deployments/$name/validate"
      verb "POST"

      field "properties" do
        location "body"
      end

      field "name" do
        location "path"
      end
    end

    action "list" do
      path "/subscriptions/$subscription_id/providers/Microsoft.Resources/deployments"
      verb "GET"
    end

    output "id","name"

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "correlationId" do
      body_path "properties.correlationId"
    end

    output "timestamp" do
      body_path "properties.timestamp"
    end

    output "outputs" do
      body_path "properties.outputs"
    end

    output "providers" do
      body_path "properties.providers[]"
    end

    output "dependencies" do
      body_path "properties.dependencies[]"
    end

    output "templateLink" do
      body_path "properties.templateLink.uri"
    end

    output "parametersLink" do
      body_path "properties.parametersLink.uri"
    end

    output "template" do
      body_path "properties.template"
    end

    output "parameters" do
      body_path "properties.parameters"
    end

    output "mode" do
      body_path "properties.mode"
    end

    provision "provision_resource"
    delete "delete_resource"
  end

  type "deployment" do
    #href_templates "{{id}}"
    href_templates "{{(type(id)=='string' && contains(id, '/resourceGroups/')) && id || null}}","{{(type(value)=='array' && contains(value[0].id, '/resourceGroups/')) && value[].id || null}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "properties" do
      type "composite"
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

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Resources/deployments/$name"
      verb "PUT"
    end

    action "get" do
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    action "update" do
      path "$href"
      verb "PUT"

      field "properties" do
        location "body"
      end
    end

    action "validate_template" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Resources/deployments/$name/validate"
      verb "POST"

      field "properties" do
        location "body"
      end

      field "resource_group" do
        location "path"
      end

      field "name" do
        location "path"
      end
    end

    action "list" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Resources/deployments"
      verb "GET"

      field "resource_group" do
        location "path"
      end
    end

    output "id","name"

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "correlationId" do
      body_path "properties.correlationId"
    end

    output "timestamp" do
      body_path "properties.timestamp"
    end

    output "outputs" do
      body_path "properties.outputs"
    end

    output "providers" do
      body_path "properties.providers[]"
    end

    output "dependencies" do
      body_path "properties.dependencies[]"
    end

    output "templateLink" do
      body_path "properties.templateLink.uri"
    end

    output "parametersLink" do
      body_path "properties.parametersLink.uri"
    end

    output "template" do
      body_path "properties.template"
    end

    output "parameters" do
      body_path "properties.parameters"
    end

    output "mode" do
      body_path "properties.mode"
    end

    provision "provision_resource"
    delete "delete_resource"
  end
end

resource_pool "azure_template" do
    plugin $azure_template
    parameter_values do
      subscription_id $subscription_id
      tenant_id $tenant_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url join(["https://login.microsoftonline.com/",$tenant_id,"/oauth2/token"])
      grant type: "client_credentials" do
        client_id cred("AZURE_APPLICATION_ID")
        client_secret cred("AZURE_APPLICATION_KEY")
        additional_params do {
          "resource" => "https://management.azure.com/"
        } end
      end
    end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = azure_template.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    sleep(5)
    @resource = @operation.get()
    sleep(5)
    $status = @resource.provisioningState
    sub on_error: skip, timeout: 60m do
      while $status == "Running" || $status == "Accepted" do
        $status = @resource.provisioningState
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end
    
    $status = @resource.provisioningState
    if $status != "Succeeded"
      raise "Azure Deployment was not successfully provisioned.  See audit entry and/or Azure Activity Log for more information"
    end
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  @declaration.destroy()
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
