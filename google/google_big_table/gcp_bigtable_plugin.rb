name "Google Big Table Plugin"
rs_ca_ver 20161221
short_description "Google Big Table plugin"
long_description "Version: 1.0"
type 'plugin'
package "plugins/bigtable"
import "sys_log"

parameter "google_project" do
  type "string"
  label "Google Cloud Project"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

plugin "bigtable" do
  endpoint do
    default_scheme "https"
    default_host "bigtableadmin.googleapis.com"
    path "/v2"
  end

  parameter "project" do
    type "string"
    label "Project"
    description "The GCP Project to create/manage resources"
  end


  # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances
  type "instances" do
    href_templates "{{!contains(name, 'clusters') && !contains(name, 'tables') && !contains(name, 'operations') && name || null}}"
    provision "provision_resource"
    delete "delete_resource"

    field "instance_id" do
      alias_for "instanceId"
      required true
      type "string"
      location "body"
    end

    field "instance" do
      type "object"
      location "body"
      required true
    end

    field "clusters" do
      type "composite"
      location "body"
    end

    field "display_name" do
      alias_for "displayName"
      type "string"
      location "body"
    end

    field "type" do
      type "string"
      location "body"
    end

    field "name" do
      type "string"
      location "path"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/create
    action "create" do 
      verb "POST"
      path "/projects/$project/instances"
      type "operation"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/delete
    action "destroy" do 
      verb "DELETE"
      path "$href"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/get
    action "get" do 
      verb "GET"
      path "$href"
    end

    action "show" do
      verb "GET"
      path "/projects/$project/instances/$name"

      field "name" do
        location "path"
      end
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/list
    action "list" do 
      verb "GET"
      path "/projects/$project/instances"
      output_path "instances[]"
    end 

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/update
    action "update" do
      verb "PUT"
      path "$href"
    end

    output "name","displayName","state","type"

  end

  # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters
  type "clusters" do
    href_templates "{{contains(name, 'clusters') && !contains(name, 'tables') && !contains(name, 'operations') && name || null}}"
    provision "provision_resource"
    delete "delete_resource"

    field "instance_id" do
      required true
      type "string"
      location "path"
    end

    field "cluster_id" do
      required true
      type "string"
      location "query"
      alias_for "clusterId"
    end

    field "location" do
      type "string"
      location "body"
    end

    field "serve_nodes" do
      alias_for "serveNodes"
      type "number"
      location "body"
    end

    field "default_storage_type" do
      type "string"
      location "body"
    end

    field "name" do
      type "string"
      location "path"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/create
    action "create" do 
      verb "POST"
      path "/projects/$project/instances/$instance_id/clusters"
      type "operation"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/delete
    action "destroy" do 
      verb "DELETE"
      path "$href"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/get
    action "get" do 
      verb "GET"
      path "$href"
    end

    action "show" do
      verb "GET"
      path "/projects/$project/instances/$instance_id/clusters/$name"

      field "name" do
        location "path"
      end

      field "instance_id" do
        location "path"
      end 
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/list
    action "list" do 
      verb "GET"
      path "/projects/$project/instances/$instance_id/clusters"
      output_path "clusters[]"
    end 

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/update
    action "update" do
      verb "PUT"
      path "$href"
    end

    output "name","location","state","serveNodes","defaultStorageType"

  end

  # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables
  type "tables" do
    href_templates "{{contains(name, 'tables') && !contains(name, 'clusters') && !contains(name, 'operations') && name || null}}"
    provision "provision_resource"
    delete "delete_resource"

    field "instance_id" do
      required true
      type "string"
      location "path"
    end

    field "table_id" do
      required true
      type "string"
      location "body"
      alias_for "tableId"
    end

    field "table" do
      type "object"
      location "body"
    end

    field "initial_splits" do
      alias_for "initialSplits"
      type "object"
      location "body"
    end

    field "view" do
      type "string"
      location "query"
    end

    field "row_key_prefix" do
      type "string"
      location "body"
      alias_for "rowKeyPrefix"
    end

    field "delete_all_data" do
      type "boolean"
      location "body"
      alias_for "deleteAllDataFromTable"
    end

    field "modifications" do
      type "array"
      location "body"
    end

    field "name" do
      type "string"
      location "path"
    end 

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/create
    action "create" do 
      verb "POST"
      path "/projects/$project/instances/$instance_id/tables"
      type "tables"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/delete
    action "destroy" do 
      verb "DELETE"
      path "$href"
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/get
    action "get" do 
      verb "GET"
      path "$href"
    end

    action "show" do
      verb "GET"
      path "/projects/$project/instances/$instance_id/tables/$name"

      field "name" do
        location "path"
      end 

      field "instance_id" do
        location "path"
      end 
    end

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/list
    action "list" do 
      verb "GET"
      path "/projects/$project/instances/$instance_id/tables"
      output_path "tables[]"
    end
    
    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/dropRowRange
    action "drop_rows" do
      verb "POST"
      path "$href:dropRowRange"
    end 

    # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/modifyColumnFamilies
    action "modify_families" do
      verb "POST"
      path "$href:modifyColumnFamilies"
    end 


    output "name","location","state","serveNodes","defaultStorageType"

  end

  # https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/operations
  type "operation" do
    href_templates "{{contains(name, 'operations') && name || null}}"
    provision "no_operation"
    delete "no_operation"

    action "get" do
      verb "GET"
      path "$href"
    end 

    output "name","metadata","done","error","response"
  end 

end 

resource_pool "bigtable" do
  plugin $bigtable
  parameter_values do
    project $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GOOGLE_BIGTABLE_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/bigtable.admin"
      } end
      signing_key cred("GOOGLE_BIGTABLE_PLUGIN_PRIVATE_KEY")
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
  @operation = bigtable.$type.create($fields)
  call sys_log.detail(to_object(@operation))
  call stop_debugging()
  call start_debugging()
  sub timeout: 2m, on_timeout: skip do
    sleep_until(@operation.done == "true")
  end
  if $type == "instances"
    $instance_id = $fields["instance_id"]
    @resource = bigtable.instances.show(name: $instance_id )
  elsif $type == "clusters"
    $instance_id = $fields["instance_id"]
    $cluster_id = $fields["cluster_id"]
    @resource = bigtable.clusters.show(instance_id: $instance_id, name: $cluster_id)
  elsif $type == "tables"
    $instance_id = $fields["instance_id"]
    $table_id = $fields["table_id"]    
    @resource = bigtable.tables.show(instance_id: $instance_id, name: $table_id)
  end 
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
      @operation = @resource.destroy()
      call sys_log.detail(to_object(@operation))
    end
  end
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