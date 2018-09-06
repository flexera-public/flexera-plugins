name "Google Deployment Manager"
rs_ca_ver 20161221
short_description "Google Deployment Manager plugin"
long_description "Version: 1.0"
type 'plugin'
package "plugins/gce_dm"
import "sys_log"

parameter "gce_project" do
  type "string"
  label "GCE Project"
  category "GCE Plugin"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

plugin "gce_dm" do
  endpoint do
    default_scheme "https"
    default_host "www.googleapis.com"
    path "/"
  end

  parameter "gce_project" do
    type "string"
    label "Project"
    description "The GCE project to create resources in"
  end

  type "deployment" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.addresses[].selfLink}}"

    field "name" do
      required true
      type "string"
    end

    field "target" do
      required true
      type "composite"
    end

    field "labels" do
      type "composite"
    end
 
    output "kind","id","creationTimestamp","name","zone","clientOperationId","operationType","targetLink","targetId","status","statusMessage","user","progress","insertTime","startTime","endTime","error","warnings","httpErrorStatusCode","httpErrorMessage","selfLink","region","description"

    # This action was generated using the documentation from https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/delete.
    action "delete" do
      verb "DELETE"
      path "$href"
    end

    # This action was generated using the documentation from https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/get.
    action "get" do
      verb "GET"
      path "$href"
    end

    # This action was generated using the documentation from https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/insert.
    action "insert" do
      verb "POST"
      path "/deploymentmanager/v2/projects/$gce_project/global/deployments"
    end

    action "cancelPreview" do
      verb "POST"
      path "$href/cancelPreview"
    end

    action "list" do
      verb "GET"
      path "/deploymentmanager/v2/projects/$gce_project/global/deployments"
    end

    action "patch" do
      verb "PATCH"
      path "$href"
    end

    action "stop" do
      verb "POST"
      path "$href/stop"
    end

    action "update" do
      verb "PUT"
      path "$href"
    end

    action "show" do
      verb "GET"
      path "$operation_href"
      field "operation_href" do
        location "path"
      end 
    end

    provision "provision_resource"
    delete "delete_resource"

  end
end

define no_operation() do
end

define provision_resource(@raw) return @resource on_error: stop_debugging() do
  $raw = to_object(@raw)
  $fields = $raw["fields"]
  $type = $raw["type"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  @operation = gce_dm.$type.empty()
  call start_debugging()
  sub on_error: stop_debugging() do
    @operation = gce_dm.$type.insert($fields)
  end
  call stop_debugging()
  call sys_log.detail(to_object(@operation))
  call start_debugging()
  sub timeout: 2m, on_timeout: skip, on_error: stop_debugging() do
    sleep_until @operation.status == "DONE"
  end
  call sys_log.detail(to_object(@resource))
  call start_debugging()
  @resource = @operation.show(operation_href: @operation.targetLink)
  call stop_debugging()
end

define delete_resource(@resource) on_error: stop_debugging() do
  call start_debugging()
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    sub on_error: skip_not_found_error() do
      @operation = @resource.delete()
      sub timeout: 2m, on_timeout: skip do
        sleep_until(@operation.status == "DONE")
      end
      call sys_log.detail(to_object(@operation))
    end
  end
end

define skip_not_found_error() do
  if $_error["message"] =~ "/not found/i"
    log_info($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "skip"
  end
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

define get_google_import($filename) return $data do
  if $$audit_targets == null
    call sys_log.set_task_target(@@deployment)
  end
  call sys_log.summary("Imports")
  task_label(join(["Getting Content for file: ", $filename]))
  $response = http_get(
      url: join(["https://raw.githubusercontent.com/GoogleCloudPlatform/deploymentmanager-samples/master/templates/", $filename])
  )
  call sys_log.detail(join(["Filename: ", $filename, " response: ", $response["code"]]))
  if $response["code"] != 200
    raise join(["File: ", $filename, " Response: ", $response])
  end
  $data = { "name" => $filename, "content" => $response["body"] }
end

define get_additional_import($hash) return $data do
  call sys_log.summary("Imports")
  task_label(join(["Getting Content for file: ", $hash["name"]]))
  $response = http_get(
      url: $hash["url"]
  )
  call sys_log.detail(join(["Filename: ", $hash["name"], " response: ", $response["code"]]))
  if $response["code"] != 200
    raise join(["File: ", $hash["name"]," Response: ", $response])
  end
  $data = { "name" => $hash["name"], "content" => $response["body"] }
end

resource_pool "gce" do
  plugin $gce_dm
  parameter_values do
    gce_project $gce_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GCE_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/cloud-platform"
      } end
      signing_key cred("GCE_PLUGIN_PRIVATE_KEY")
    end
  end
end