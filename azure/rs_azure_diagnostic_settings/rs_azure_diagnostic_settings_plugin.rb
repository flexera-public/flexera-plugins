name 'rs_azure_diagnostic_settings'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure - ARM Diagnostic Settings"
long_description "Version: 1.0"
package "plugins/rs_azure_diagnostic_settings"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

plugin "rs_azure_diagnostic_settings" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      "api-version" => "2016-09-01"
    } end
  end

  parameter "subscription_id" do
    type      "string"
    label "subscription_id"
  end

  type "diagnostic_settings" do
    href_templates "{{id}}"
    provision "provision_resource"
    delete "no_operation"

    field "properties" do
      type "composite"
      location "body"
      required true
    end

    field "resource_uri" do
      type "string"
      location "path"
      required true
    end

    field "location" do
      type "string"
      location "body"
      required true
    end

    action "create" do
      path "$resource_uri/providers/microsoft.insights/diagnosticSettings/service"
      verb "PUT"
    end

    action "update" do
      path "$href"
      verb "PATCH"

      field "properties" do
        location "body"
      end
    end

    action "get" do
      path "$resource_uri/providers/microsoft.insights/diagnosticSettings/service"
      verb "GET"

      field "resource_uri" do
        location "path"
      end
    end

    output "id","name"
  end
end

resource_pool "rs_azure_diagnostic_settings" do
    plugin $rs_azure_diagnostic_settings
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
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_azure_diagnostic_settings.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
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