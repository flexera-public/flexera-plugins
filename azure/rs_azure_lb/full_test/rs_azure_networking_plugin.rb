name 'rs_azure_networking_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Networking Plugin"
long_description "Version: 1.2"
package "plugins/rs_azure_networking_plugin"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_networking_interfaces" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2016-09-01'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "interface" do
    href_templates "{{id}}","{{value[*].id}}"
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

    action "create" do
      type "interface"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Network/networkInterfaces/$name"
      verb "PUT"
    end

    action "update" do
      type "interface"
      path "$href"
      verb "PUT"
    end

    action "show" do
      type "interface"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Network/networkInterfaces/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      field "name" do
        location "path"
      end
    end

    action "list" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Network/networkInterfaces"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      output_path "value[*]"
    end

    action "get" do
      type "interface"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "interface"
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","properties"
  end
end

plugin "rs_azure_lb" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2016-09-01'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "load_balancer" do
    href_templates "{{id}}"
    provision "provision_lb"
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
    
    field "frontendIPConfigurations" do
      type "composite"
      location "body"
    end

    field "backendAddressPools" do
      type "composite"
      location "body"
    end

    field "loadBalancingRules" do
      type "composite"
      location "body"
    end

    field "probes" do
      type "composite"
      location "body"
    end

    field "inboundNatPools" do
      type "composite"
      location "body"
    end

    field "inboundNatRules" do
      type "composite"
      location "body"
    end

    action "create" do
      type "load_balancer"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Network/loadBalancers/$name"
      verb "PUT"
    end

    action "show" do
      type "load_balancer"
      path "$href"
      verb "GET"
    end

    action "get" do
      type "load_balancer"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "load_balancer"
      path "$href"
      verb "DELETE"
    end

    output "id","name","location","tags","etag"

    output "state" do
      body_path "properties.provisioningState"
    end

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "frontendIPConfigurations" do
      body_path "properties.frontendIPConfigurations"
    end

    output "backendAddressPools" do
      body_path "properties.backendAddressPools"
    end

    output "loadBalancingRules" do
      body_path "properties.loadBalancingRules"
    end

    output "probes" do
      body_path "properties.probes"
    end

    output "inboundNatRules" do
      body_path "properties.inboundNatRules"
    end

    output "inboundNatPools" do
      body_path "properties.inboundNatPools"
    end
  end
end

resource_pool "rs_azure_networking_interfaces" do
    plugin $rs_azure_networking_interfaces
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

resource_pool "rs_azure_lb" do
    plugin $rs_azure_lb
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

define provision_lb(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    if $fields["properties"] == null
      $create_fields = {}
      $create_fields["resource_group"] = $fields["resource_group"]
      $create_fields["name"] = $fields["name"]
      $create_fields["location"] = $fields["location"]
      $create_fields["tags"] = $fields["tags"]
      $create_fields["properties"] = {}
      $create_fields["properties"]["frontendIPConfigurations"] = $fields["frontendIPConfigurations"]
      $create_fields["properties"]["backendAddressPools"] = $fields["backendAddressPools"]
      $create_fields["properties"]["loadBalancingRules"] = $fields["loadBalancingRules"]
      $create_fields["properties"]["probes"] = $fields["probes"]
      $create_fields["properties"]["inboundNatPools"] = $fields["inboundNatPools"]
      $create_fields["properties"]["inboundNatRules"] = $fields["inboundNatRules"]
    else
      $create_fields = $fields
    end
    call sys_log.detail(join(["fields", $create_fields]))
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_lb.$type.create($create_fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show()
    $status = @resource.state
    sub on_error: skip, timeout: 60m do
      while $status != "Succeeded" do
        $status = @resource.state
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
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
    @operation = rs_azure_networking_interfaces.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show(resource_group: $resource_group, name: $name)
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_extension(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    $vm_name = $fields["virtualMachineName"]
    call sys_log.detail(join(["fields", $fields]))
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_networking_interfaces.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @new_resource = @operation.show(resource_group: $resource_group, virtualMachineName: $vm_name, name: $name)
    $status = @new_resource.state
    while $status != "Succeeded" do
      $status = @new_resource.state
      if $status == "Failed"
        call stop_debugging()
        raise "Execution Name: "+ $name + ", Status: " + $status + ", VirtualMachine: " + $vm_name
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