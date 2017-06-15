name "Google Cloud DNS"
rs_ca_ver 20161221
short_description "Google Cloud DNS plugin"
type 'plugin'
package "plugins/googledns"
import "sys_log"

parameter "google_project" do
  type "string"
  label "Google Cloud Project"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

plugin "clouddns" do
    endpoint do
        default_scheme "https"
        default_host "www.googleapis.com"
        path "/dns/v1"
    end

    parameter "project" do
        type "string"
        label "Project"
        description "The GCP Project to create/manage resources"
    end

    # https://cloud.google.com/dns/api/v1/changes
    type "change" do
        href_templates "{{id}}"

        field "managed_zone" do
            location "path"
            required true
            type "string"
        end

        field "address" do
            type "string"
        end

        field "description" do
            type "string"
        end

        field "name" do
            required true
            type "string"
        end

        output "address","creationTimestamp","description","id","kind","name","region","selfLink","status","users"

        # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/aggregatedList.
        action "create" do 
            verb "POST"
            path "/projects/$project/managedZones/$managed_zone"
            type "address"
            output_path "items.*.addresses[]"
        end

        # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/delete.
        action "delete" do 
            verb "DELETE"
            path "$href"
            type "operation"
        end

        # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/get.
        action "get" do 
            verb "GET"
            path "$href"
            type "address"
        end

        # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/insert.
        action "insert" do 
            verb "POST"
            path "/projects/$project/regions/$region/addresses"
            type "operation"
        end

        # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/list.
        action "list" do 
            verb "GET"
            path "/projects/$project/regions/$region/addresses"
            type "address"
            output_path "items"
        end

        link "region" do
            url "$region"
            type "region"
        end

        provision "provision_resource"

        delete "delete_resource"

    end

    # https://cloud.google.com/dns/api/v1/managedZones
    type "managedZone" do
        href_templates "{{id}}"

        field "name" do
            required true
            type "string"
        end

        field "description" do
            type "string"
        end

        field "dns_name" do
            required true
            type "string"
        end

        field "nameserver_set"
            type "string"
        end

        output "creationTime","description","dnsName","id","kind","name","nameServerSet","nameServers"

        output_path "items"

        # https://cloud.google.com/dns/api/v1/managedZones/create
        action "create" do 
            verb "POST"
            path "/projects/$project/managedZones"
        end

        # https://cloud.google.com/dns/api/v1/managedZones/delete
        action "delete" do 
            verb "DELETE"
            path "/projects/$project/managedZones/$href"
        end

        # https://cloud.google.com/dns/api/v1/managedZones/get 
        action "get" do 
            verb "GET"
            path "/projects/$project/managedZones/$href"
        end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/insert.
    action "insert" do 
      verb "POST"
      path "/projects/$project/regions/$region/addresses"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/addresses/list.
    action "list" do 
      verb "GET"
      path "/projects/$project/regions/$region/addresses"
      type "address"
      output_path "items"
    end

    link "region" do
      url "$region"
      type "region"
    end

    provision "provision_resource"

    delete "delete_resource"

  end
define no_operation() do
end

define provision_resource(@raw) return @resource on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@raw)
  $fields = $raw["fields"]
  $type = $raw["type"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  @operation = gce.$type.insert($fields)
  call sys_log.detail(to_object(@operation))
  sub timeout: 2m, on_timeout: skip do
    sleep_until @operation.status == "DONE"
  end
  call sys_log.detail(to_object(@resource))
  @resource = @operation.targetLink()
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
resource_pool "gce" do
  plugin $gce
  parameter_values do
    project $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GCE_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/compute"
      } end
      signing_key cred("GCE_PLUGIN_PRIVATE_KEY")
    end
  end
end

