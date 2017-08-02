name "rs_riverbed_steelhead"
type "plugin"
rs_ca_ver 20161221
short_description "Riverbed Steelhead Plugin"
long_description "Version: 1.0"
package "plugins/rs_riverbed_steelhead"
import "sys_log"


plugin "rs_riverbed_steelhead" do
  endpoint do
    default_host "54.163.44.115"
    default_scheme "http"
    headers do {
      "Content-Type" => "application/json"
    } end
  end

  type "server" do
    href_templates "{{}}"
    provision "provision_resource"
    delete "no_operation"

    field "name" do
      location "body"
      type "string"
    end

    action "show" do
      type "current_configuration"
      path "/api"
      verb "GET"
    end
  end
end

resource_pool "rs_riverbed_steelhead" do
  plugin $rs_riverbed_steelhead
  auth "basic_auth", type: "basic" do
    username "admin"
    password "i-005baaeb9fe38269e"
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
    call sys_log.set_task_target(@@deployment)
    call sys_log.detail($object)
    call start_debugging()
    @resource = rs_riverbed_steelhead.server.show()
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

resource "server", type: "rs_riverbed_steelhead.server" do
  name "simpleton"
end