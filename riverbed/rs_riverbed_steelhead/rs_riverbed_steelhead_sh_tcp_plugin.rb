name "rs_riverbed_steelhead_sh_tcp"
type "plugin"
rs_ca_ver 20161221
short_description "Riverbed Steelhead Plugin"
long_description "Version: 1.0"
package "plugins/rs_riverbed_steelhead_sh_tcp"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

plugin "rs_riverbed_steelhead_sh_tcp" do
  endpoint do
    default_host cred("STEELHEAD_HOST")
    default_scheme "https"
    headers do {
      "Content-Type": "application/json"
    } end
  end

  type "cong_ctrl_options_available" do
    href_templates "/api/sh.tcp/1.0/cong_ctrl_options_available"
    provision "no_operation"
    delete "no_operation"

    action "show" do
      type "cong_ctrl_options_available"
      path "/api/sh.tcp/1.0/cong_ctrl_options_available"
      verb "GET"
    end
    outputs "items"
  end

  type "cong_ctrl" do
    href_templates "/api/sh.tcp/1.0/cong_ctrl"
    provision "no_operation"
    delete "no_operation"

    field "mode" do
      location "body"
      type "string"
    end

    action "show" do
      type "cong_ctrl"
      path "/api/sh.tcp/1.0/cong_ctrl"
      verb "GET"
    end

    action "create" do
      type "cong_ctrl"
      path "/api/sh.tcp/1.0/cong_ctrl"
      verb "PUT"
    end

    action "get" do
      type "cong_ctrl"
      path "/api/sh.tcp/1.0/cong_ctrl"
      verb "GET"
    end

    action "set" do
      type "cong_ctrl"
      path "/api/sh.tcp/1.0/cong_ctrl"
      verb "GET"
    end
    outputs "mode"
  end

  type "rate_cap" do
    href_templates "/api/sh.tcp/1.0/rate_cap"
    provision "no_operation"
    delete "no_operation"

    field "enabled" do
      type "boolean"
      body "path"
    end

    action "show" do
      type "rate_cap"
      path "/api/sh.tcp/1.0/rate_cap"
      verb "GET"
    end
    outputs "enabled"
  end

  type "cong_ctrl_options_available" do
    href_templates "/api/sh.tcp/1.0/cong_ctrl_options_available"
    provision "no_operation"
    delete "no_operation"

    action "show" do
      type "cong_ctrl_options_available"
      path "/api/sh.tcp/1.0/cong_ctrl_options_available"
      verb "GET"
    end
    outputs "items"
  end
end

resource_pool "rs_riverbed_steelhead" do
  plugin $rs_riverbed_steelhead_sh_tcp
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