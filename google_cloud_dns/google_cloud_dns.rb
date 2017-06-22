
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

parameter "dns_zone" do
  type "string"
  label "Zone Name/ID"
  description "The DNS Zone Name (or DNS Zone ID) to create/manage"
  # Needed to manage DNS Records (type = resourceRecordSet)
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

  parameter "managed_zone" do
    type "string"
    label "Zone Name/ID"
    description "The DNS Zone Name (or DNS Zone ID) to create/manage"
  end 

  # https://cloud.google.com/dns/api/v1/changes
  type "change" do
    href_templates "/changes/{{id}}","/changes/{{changes[*].id}}"

    field "managed_zone" do
      location "path"
      required true
      type "string"
    end

    field "kind" do
      type "string"
    end 

    field "additions" do
      type "object"
    end

    field "deletions" do
      type "object"
    end 

    #Optional fields for non-create calls
    field "id" do
      alias_for "changeId"
      type "string"
      location "path"
    end

    output "kind","startTime","id","status"

    # https://cloud.google.com/dns/api/v1/changes/create
    action "create" do
      verb "POST"
      path "/projects/$project/managedZones/$managed_zone/changes"
    end 

    # https://cloud.google.com/dns/api/v1/changes/create
    action "delete" do
      verb "POST"
      path "/projects/$project/managedZones/$managed_zone/changes"
    end 

    # https://cloud.google.com/dns/api/v1/changes/get
    action "get" do
      verb "GET"
      path "/projects/$project/managedZones/$managed_zone/$href"

      field "managed_zone" do
        location "path"
      end
    
    end

    # https://cloud.google.com/dns/api/v1/changes/list
    action "list" do
      verb "GET"
      path "/projects/$project/managedZones/$managed_zone/changes"
      output_path "changes[]"

      field "managed_zone" do
        location "path"
      end
    end 

    provision "provision_resource"

    delete "delete_resource"

  end

  # https://cloud.google.com/dns/api/v1/managedZones
  type "managedZone" do
    href_templates "/projects/$project/managedZones/{{id}}"

    field "name" do
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "dns_name" do
      alias_for "dnsName"
      required true
      type "string"
    end

    field "nameserver_set" do 
      alias_for "nameServerSet"
      type "string"
    end

    field "kind" do
      type "string"
    end

    #Optional fields for non-create calls
    field "max_results" do 
      type "number"
      location "query"
      alias_for "maxResults"
    end

    output "creationTime","description","dnsName","id","kind","name","nameServerSet","nameServers"

    # https://cloud.google.com/dns/api/v1/managedZones/create
    action "create" do 
      verb "POST"
      path "/projects/$project/managedZones"
    end

    # https://cloud.google.com/dns/api/v1/managedZones/delete
    action "delete" do 
      verb "DELETE"
      path "$href"
    end

    # https://cloud.google.com/dns/api/v1/managedZones/get 
    action "get" do 
      verb "GET"
      path "$href"
    end

    # https://cloud.google.com/dns/api/v1/managedZones/list
    action "list" do 
      verb "GET"
      path "/projects/$project/managedZones"
      output_path "managedZones[]"

      field "max_results" do 
        location "query"
        alias_for "maxResults"
      end 
    end 

    link "project" do
      path "/projects/$project"
      type "project"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # https://cloud.google.com/dns/api/v1/projects 
  type "project" do
    href_templates "/projects/{{id}}"

    # https://cloud.google.com/dns/api/v1/projects/get
    action "get" do 
      verb "GET"
      path "/projects/$project"
    end 

    output "kind","number","id"

    output "managedZones_quota" do
      body_path "quota.managedZones"
    end 

    output "resourceRecordsPerRrset_quota" do
      body_path "quota.resourceRecordsPerRrset"
    end 

    output "rrsetAdditionsPerChange_quota" do
      body_path "quota.rrsetAdditionsPerChange"
    end 

    output "rrsetDeletionsPerChange_quota" do
      body_path "quota.rrsetDeletionsPerChange"
    end 

    output "rrsetsPerManagedZone_quota" do
      body_path "quota.rrsetsPerManagedZone"
    end 

    output "totalRrdataSizePerChange_quota" do
      body_path "quota.totalRrdataSizePerChange"
    end 

    provision "no_operation"

    delete "no_operation"

  end

type "resourceRecordSet" do
    href_templates "?name={{additions[*].name}}","?name={{deletions[*].name}}","?name={{rrsets[*].name}}"

    field "record" do
      type "array"
      required true
    end

    #Optional fields for non-create calls
    field "max_results" do 
      type "number"
      location "query"
      alias_for "maxResults"
    end 

    field "name" do
      type "string"
      location "query"
      # Note: Required if "type" field is specified
    end 

    field "type" do
      type "string"
      location "query"
    end

    # https://cloud.google.com/dns/api/v1/changes/create
    action "create" do
      verb "POST"
      path "/projects/$project/managedZones/$managed_zone/changes"
      output_path "additions[]"

      field "record" do
        alias_for "additions"
      end
    end

    # https://cloud.google.com/dns/api/v1/changes/create
    action "delete" do
      verb "POST"
      path "/projects/$project/managedZones/$managed_zone/changes"

      field "record" do
        alias_for "deletions"
      end 

    end

    # https://cloud.google.com/dns/api/v1/resourceRecordSets/list
    action "list" do
      verb "GET"
      path "/projects/$project/managedZones/$managed_zone/rrsets"

      field "max_results" do 
        location "query"
        alias_for "maxResults"
      end 

      field "name" do
        location "query"
        # Note: Required if "type" field is specified
      end 

      field "type" do
        location "query"
      end

    end 

    action "show" do
      verb "GET"
      path "/projects/$project/managedZones/$managed_zone/rrsets$href"
    end


    output "kind","name","type","ttl","rrdatas"

    output_path "rrsets[]" 

    provision "provision_rrset"

    delete "delete_rrset"
  
  end  

end 

resource_pool "clouddns" do
  plugin $clouddns
  parameter_values do
    project $google_project
    managed_zone $dns_zone
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GOOGLE_DNS_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/ndev.clouddns.readwrite"
      } end
      signing_key cred("GOOGLE_DNS_PLUGIN_PRIVATE_KEY")
    end
  end
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
  @operation = clouddns.$type.create($fields)
  call sys_log.detail(to_object(@operation))
  if $type == "change"
    sub timeout: 2m, on_timeout: skip do
      sleep_until @operation.status == "done"
    end
  end 
  @resource = @operation.get()
  call sys_log.detail(to_object(@resource))
  call stop_debugging()
end

define delete_resource(@resource) on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@resource)
  $type = $raw["type"]
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    sub on_error: skip_not_found_error() do
      @operation = @resource.delete()
      if $type == "change"
        sub timeout: 2m, on_timeout: skip do
          sleep_until(@operation.status == "done")
        end
      end 
      call sys_log.detail(to_object(@operation))
    end
  end
  call stop_debugging()
end

define provision_rrset(@raw) return @resource on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@raw)
  $fields = $raw["fields"]
  $type = $raw["type"]
  $record = $fields["record"][0]
  $name = $record["name"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  call sys_log.detail(join(["fields: ", $fields]))
  call sys_log.detail(join(["record: ", $record]))
  call sys_log.detail(join(["name: ", $name]))
  @operation = clouddns.resourceRecordSet.create($fields)
  call sys_log.detail(to_object(@operation))
  @resource = @operation.show()
  call sys_log.detail(to_object(@resource))
  call stop_debugging()
end

define delete_rrset(@resource) on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@resource)
  $fields = $raw["details"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Delete: ",$type]))
  call sys_log.detail(join(["fields: ", $fields]))
  #sub on_error: stop_debugging() do
    @operation = clouddns.resourceRecordSet.delete(record: $fields)
    call sys_log.detail(to_object(@operation))
  #end
  call stop_debugging()
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

