name 'kubernetes'
type 'plugin'
rs_ca_ver 20161221
short_description "kubernetes"
long_description "Version: 0.3"
package "kubernetes"
import "sys_log"


parameter "kubernetes_host" do
  type "string"
  label "kubernetes host"
end

parameter "kubernetes_key" do
  type "string"
  label "kubernetes_key"
end

plugin "kubernetes" do
  endpoint do
    default_scheme "https"
    no_cert_check true
  end

  parameter "kubernetes_host" do
    type "string"
    label "kubernetes host"
  end
  
  parameter "kubernetes_key" do
    type "string"
    label "kubernetes_key"
  end  

  type "pods" do
    href_templates "{{metadata.selfLink}}","{{items[*].metadata.selfLink}}","{{selfLink}}"
    provision "provision_resource"
    delete    "delete_resource"

    action "create" do
      type "pods"
      path "/api/v1/namespaces/default/pods/"
      verb "PUT"
    end

    action "show" do
      path "/api/v1/namespaces/default/pods/"
      verb "GET"
    end

    action "get" do
      type "pods"
      path "$href"
      verb "GET"
    end

    action "list" do
      type "pods"
      path "/api/v1/namespaces/default/pods/"
      verb "GET"
      output_path "items[*]"
    end

    action "destroy" do
      type "pods"
      path "$href"
      verb "DELETE"
    end

    output "metadata","spec", "status"

    output "selfLink" do
      body_path "metadata.selfLink"
    end

    output "name" do
      body_path "metadata.name"
    end

    output "labels" do
      body_path "metadata.labels"
    end

    output "containers" do
      body_path "spec.containers"
    end

    output "volumes" do
      body_path "spec.volumes"
    end

    output "volumeMounts" do
      body_path "spec.volumeMounts"
    end
  end
end

resource_pool "kubernetes" do
  plugin $kubernetes

  parameter_values do
    kubernetes_host $kubernetes_host
    kubernetes_key $kubernetes_key
  end

  host $kubernetes_host
  auth "kubernetes_api_key", type: "api_key" do
    # API key value
    # Uses standard CAT field syntax
    key $kubernetes_key
    # Location of the authorization, "header" or "query" - defaults to "header"
    location "header"
    # Name of either the authorization header key or the query parameter field (defaults to "Authorization")
    field "Authorization"
    # Type of authorization header, prefixes the key value (defaults to "Bearer")
    type "Bearer"
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
    @operation = rs_azure_aks.$type.create($fields)
    call stop_debugging()
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.detail("entering check for aks created")
    sub on_error: retry, timeout: 30m do
      call sys_log.detail("sleeping 10")
      sleep(10)
      call start_debugging()
      @new_resource = @operation.show(name: $name, resource_group: $resource_group )
      call stop_debugging()
    end
    call sys_log.detail("Checking that aks state is online")
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    $status = @new_resource.state
    call sys_log.detail(join(["Status: ", $status]))
    sub on_error: skip, timeout: 30m do
      while $status != "Succeeded" do
        $status = @operation.show(name: $name, resource_group: $resource_group).state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        call start_debugging()
        sleep(10)
      end
    end
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group )
    @resource = @new_resource
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