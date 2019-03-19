name 'rs_azure_application_gateway'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Application Gateway Plugin"
long_description "Version: 1.0"
package "plugins/rs_azure_application_gateway"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

parameter "tier" do
  type  "string"
  label "Tier"
  allowed_values "Standard", "WAF"
  default "Standard"
end

parameter "instance_count" do
  type  "number"
  label "Instance Count"
  default 1
end

parameter "sku" do
  type  "string"
  label "SKU Size"
  allowed_values "Small", "Medium","Large"
  default "Small"
end

parameter "ssl_cred" do
  type  "string"
  label "SSL Certificate Credential"
  description "Provide the SSL Certificate Credential to be used."
end

parameter "ssl_cred_password" do
  type  "string"
  label "SSL Certificate Password Credential "
  description "Provide the SSL Certificate password Credential to be used."
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_application_gateway" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2018-11-01'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "gateway" do
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

    field "tags" do
      type "composite"
      location "body"
    end

    field "zones" do
      type "composite"
      location "body"
    end

    field "identity" do
      type "composite"
      location "body"
    end

    action "create" do
      type "gateway"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Network/applicationGateways/$name"
      verb "PUT"
    end

    action "show" do
      type "gateway"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Network/applicationGateways/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      field "name" do
        location "path"
      end
    end

    action "get" do
      type "gateway"
      path "$href"
      verb "GET"
    end

    action "update" do
      type "gateway"
      path "$href"
      verb "PUT"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","properties","type"

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "state" do
      body_path "properties.provisioningState"
    end

    output "operationalState" do
      body_path "properties.operationalState"
    end

   end
end

resource_pool "rs_azure_application_gateway" do
    plugin $rs_azure_application_gateway
    parameter_values do
      subscription_id $subscription_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/881ff53d-5163-49bd-9d6b-09fa993dd1f5/oauth2/token"
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
    @operation = rs_azure_application_gateway.$type.create($fields)
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
