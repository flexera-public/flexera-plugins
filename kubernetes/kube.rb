name 'kubernetes'
type 'plugin'
rs_ca_ver 20161221
short_description "kubernetes"
long_description "Version: 0.1"
package "kubernetes"
import "sys_log"

plugin "kubernetes" do
  endpoint do
    default_host "A00ED3FE6156680F294E96F3B772658A.gr7.us-east-1.eks.amazonaws.com"
    default_scheme "https"
    no_cert_check "true"
  end

  type "pods" do
    href_templates "{{metadata.selfLink}}","{{items[*].metadata.selfLink}}"
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
    end

    action "destroy" do
      type "pods"
      path "$href"
      verb "DELETE"
    end

    output "metadata", "spec", "status"

    output "selfLink" do
      body_path "metadata.selfLink"
    end

    output "name" do
      body_path "metadata.name"
    end
  end
end

resource_pool "kubernetes" do
  plugin $kubernetes
  host "A00ED3FE6156680F294E96F3B772658A.gr7.us-east-1.eks.amazonaws.com"
  auth "my_API_key_auth", type: "api_key" do
    # API key value
    # Uses standard CAT field syntax
    key "eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImFwaS1leHBsb3Jlci10b2tlbi1sajVmdyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhcGktZXhwbG9yZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIyMWY5OTlkOS02MzA0LTExZWEtYjhhYy0wYTJkZmY5NWI4NWQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDphcGktZXhwbG9yZXIifQ.fA28wmtOmrcVlV7ermC9ADQIK4_mLV_Aj5OwRSkvWKJog58yFwFzkQfg4xNHdYxyQhPZ5brxc9fPQHBq_HNZX_gRFDKHXkKufTnq4U139KS_0qTyC4K36O9xZ0y8xgrT8N5Kxxd-z5nTdAMNXNFYq7adEfQFia6fb37QMtghoy2nUYQcJG6Ekkh2AQbZKFwno4cDfm3QmlYSzCv4EoRHOE6sj7A-4575qB2qaFxPY08oLp7msUvg-KTu_4lmr1SH4w-JrLu4R75cefYqK86M3LF6-DbQBIXLziOsLg5dm963M3PIdtke5Tr42tjEQDr28-yzOoGpbOfEpyH_ZoTR3w"
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

output "output_pods" do
  label "Pods"
end

operation "get_pods" do
  definition "get_pods"
  output_mappings do {
    $output_pods => $pods
  } end
end

define get_pods() return @pods,$pods do
  call start_debugging()
  @pods = kubernetes.pods.empty()
  sub on_error: stop_debugging() do
    @pods = kubernetes.pods.list()
  end
  call stop_debugging()
  $pods = to_s(@pods)
end