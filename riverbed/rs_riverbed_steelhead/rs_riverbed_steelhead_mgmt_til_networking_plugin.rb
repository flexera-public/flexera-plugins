name "rs_riverbed_steelhead_mgmt_til_networking"
type "plugin"
rs_ca_ver 20161221
short_description "Riverbed Steelhead Plugin"
long_description "Version: 1.0"
package "plugins/rs_riverbed_steelhead_mgmt_til_networking"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

plugin "rs_riverbed_steelhead_mgmt_til_networking" do
  endpoint do
    default_host cred("STEELHEAD_HOST")
    default_scheme "https"
    headers do {
      "Content-Type": "application/json"
    } end
  end

  type "interfaces" do
    href_templates "/api/mgmt.til.networking/1.0/interfaces"
    provision "no_operation"
    delete "no_operation"

    action "show" do
      type "interfaces"
      path "/api/mgmt.til.networking/1.0/interfaces"
      verb "GET"
    end
    outputs "items"
  end
  
  type "interface" do
    href_templates "/api/mgmt.til.networking/1.0/interfaces/items/{name}"
    provision "no_operation"
    delete "no_operation"

    field "name" do
      type "string"
      location "path"
    end

    action "get" do
      type "interface"
      verb "GET"
      path "$href"
    end

    action "set" do
      type "interface"
      verb "GET"
      path "/api/mgmt.til.networking/1.0/interfaces/items/$name"
    end

    action "create" do
      type "interface"
      verb "GET"
      path "/api/mgmt.til.networking/1.0/interfaces/items/$name"
    end

    outputs "name", "configuration","state"
  end

  type "ipv4_routes" do
    href_templates "/api/mgmt.til.networking/1.0/routes/ipv4"
    provision "no_operation"
    delete "no_operation"

    action "show" do
      type "ipv4_routes"
      verb "GET"
      path "$href"
    end

    outputs "all","static"
  end

  type "ipv4_route" do
    href_templates "/api/mgmt.til.networking/1.0/routes/ipv4/{id}"
    provision "no_operation"
    delete "no_operation"

    field "network_prefix" do
      type "string"
      location "body"
    end

    field "gateway_address" do
      type "string"
      location "body"
    end

    field "interface" do
      type "string"
      location "body"
    end

    action "show" do
      type "ipv4_route"
      verb "GET"
      path "$href"
    end

    action "create" do
      type "ipv4_route"
      verb "POST"
      path "/api/mgmt.til.networking/1.0/routes/ipv4"
    end

    action "destroy" do
      type "ipv4_route"
      path "$href"
      verb "DELETE"
    end

    outputs "id", "network_prefix","gateway_address", "interface"
  end

  type "ipv6_routes" do
    href_templates "/api/mgmt.til.networking/1.0/routes/ipv6"
    provision "no_operation"
    delete "no_operation"

    action "show" do
      type "ipv6_routes_routes"
      verb "GET"
      path "$href"
    end

    outputs "all","static"
  end

  type "ipv6_route" do
    href_templates "/api/mgmt.til.networking/1.0/routes/ipv6/{id}"
    provision "no_operation"
    delete "no_operation"

    field "network_prefix" do
      type "string"
      location "body"
    end

    field "gateway_address" do
      type "string"
      location "body"
    end

    field "interface" do
      type "string"
      location "body"
    end

    action "show" do
      type "ipv6_route"
      verb "GET"
      path "$href"
    end

    action "create" do
      type "ipv6_route"
      verb "POST"
      path "/api/mgmt.til.networking/1.0/routes/ipv6"
    end

    action "destroy" do
      type "ipv4_route"
      path "$href"
      verb "DELETE"
    end

    outputs "id", "network_prefix","gateway_address", "interface"
  end

  type "route_settings" do
    href_templates "/api/mgmt.til.networking/1.0/settings/route"
    provision "no_operation"
    delete "no_operation"

    field "default_gateway" do
      type "composite"
      location "body"
    end

    action "get" do
      type "interface"
      verb "GET"
      path "$href"
    end

    action "set" do
      type "interface"
      verb "GET"
      path "/api/mgmt.til.networking/1.0/settings/route"
    end

    action "create" do
      type "interface"
      verb "GET"
      path "/api/mgmt.til.networking/1.0/settings/route"
    end

    outputs "default_gateway"
    output "default_gateway_ipv4" do
      body_path "default_gateway.ipv4"
    end
    output "default_gateway_ipv6" do
      body_path "default_gateway.ipv6"
    end
  end
end

resource_pool "rs_riverbed_steelhead" do
  plugin $rs_riverbed_steelhead_mgmt_til_networking
  auth "basic_auth", type: "basic" do
    username "admin"
    password "admin"
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
    @operation = rs_azure_compute.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show(resource_group: $resource_group, name: $name)
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