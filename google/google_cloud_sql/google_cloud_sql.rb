name "Google Cloud SQL Plugin"
rs_ca_ver 20161221
short_description "Google Cloud SQL"
long_description "Version: 1.0"
type 'plugin'
package "plugins/google_sql"
import "sys_log"

parameter "google_project" do
  type "string"
  label "Google Cloud Project"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

plugin "cloud_sql" do
  endpoint do
    default_scheme "https"
    default_host "www.googleapis.com"
    path "/sql/v1beta4"
  end

  parameter "project" do
    type "string"
    label "Project"
    description "The GCP Project to create/manage resources"
  end

  type "instances" do
    href_templates "/projects/$project/instances/{{name}}","/projects/$project/instances/{{items[*].name}}"

    field "name" do
      required true
      type "string"
    end

    field "settings" do
      required true
      type "composite"
    end

    field "database_version" do
      alias_for "databaseVersion"
      type "string"
    end

    field "failover_replica" do 
      alias_for "failoverReplica"
      type "object"
    end
    
    field "master_instance_name" do
      alias_for "masterInstanceName"
      type "string"
    end

    field "on_premises_configuration" do
      alias_for "onPremisesConfiguration"
      type "composite"
    end

    field "region" do
      type "string"
    end 

    field "replica_configuration" do
      alias_for "replicaConfiguration"
      type "composite"
    end     

    #Optional fields for non-create calls
    field "max_results" do 
      location "query"
      alias_for "maxResults"
      type "number"
    end 
  
    field "filter" do 
      location "query"
      alias_for "maxResults"
      type "string"
    end 

    field "clone_context" do
      alias_for "cloneContext"
      type "composite"
    end
    
    field "failover_context" do
      alias_for "failoverContext"
      type "composite"
    end 

    field "import_context" do
      alias_for "importContext"
      type "composite"
    end 

    field "export_context" do
      alias_for "exportContext"
      type "composite"
    end 

    output "kind","selfLink","name","connectionName","etag","project","state","backendType","databaseVersion","region","currentDiskSize","maxDiskSize","settings","serverCaCert","ipAddresses","instanceType","masterInstanceName","replicaNames","failoverReplica","ipv6Address","serviceAccountEmailAddress","onPremisesConfiguration","replicaConfiguration","suspensionReason"

    action "create" do 
      verb "POST"
      path "/projects/$project/instances"
      type "operation"
    end

    action "delete" do 
      verb "DELETE"
      path "$href"
      type "operation"
    end

    action "get" do 
      verb "GET"
      path "$href"
      type "instances"
    end

    action "list" do 
      verb "GET"
      path "/projects/$project/instances"
      type "instances"
      output_path "items[]"

      field "max_results" do 
        location "query"
        alias_for "maxResults"
      end 

      field "filter" do 
        location "query"
        alias_for "maxResults"
      end 
    end 

    action "update" do
      verb "PUT"
      path "$href"
      type "instances"

      field "settings" do
        location "body"
      end
    end 

    action "restart" do
      verb "POST"
      path "$href/restart"
      type "operation"
    end 

    action "clone" do
      verb "POST"
      path "$href/clone"
      type "operation"

      field "clone_context" do
        alias_for "cloneContext"
      end
    end

    action "failover" do
      verb "POST"
      path "$href/failover"
      type "operation"

      field "failover_context" do
        alias_for "failoverContext"
      end 
    end 

    action "import" do
      verb "POST"
      path "$href/import"
      type "operation"

      field "import_context" do
        alias_for "importContext"
      end
    end 

    action "export" do
      verb "POST"
      path "$href/export"
      type "operation"

      field "export_context" do
        alias_for "exportContext"
      end
    end 

    link "databases" do
      path "$href/databases"
      type "databases"
    end

    link "users" do
      path "$href/users"
      type "users"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  type "databases" do
    href_templates "/projects/$project/instances/{{instance}}/databases/{{name}}","/projects/$project/instances/{{items[*].instance}}/databases/{{items[*].name}}"
    
    field "instance_name" do
      location "path"
      type "string"
      required true
    end 

    field "charset" do
      type "string"
      required true
    end 

    field "name" do
      type "string"
      required true
    end 

    field "collation" do
      type "string"
      required true
    end 

    action "create" do
      verb "POST"
      path "/projects/$project/instances/$instance_name/databases"
      type "operation"
    end 

    action "get" do
      verb "GET"
      path "$href"
      type "databases"
    end 

    action "delete" do
      verb "DELETE"
      path "$href"
      type "operation"
    end 

    action "list" do
      verb "GET"
      path "/projects/$project/instances/$instance_name/databases"
      type "databases"
      output_path "items[]"
    end 

    action "update" do
      verb "PUT"
      path "$href"
      type "operation"

      field "charset" do 
        location "body"
      end 

      field "collation" do
        location "body"
      end 

    end 

    output "charset","collation","etag","instance","kind","name","project","selfLink"

    provision "provision_resource"
    
    delete "delete_resource"


  end

  type "users" do
    href_templates "/projects/$project/instances/{{instance}}/users","/projects/$project/instances/{{items[*].instance}}/users"
    
    field "instance_name" do
      location "path"
      type "string"
      required true
    end 

    field "name" do
      type "string"
      required true
    end 

    field "host" do
      type "string"
    end 

    field "password" do
      type "string"
      required true
    end 

    action "create" do
      verb "POST"
      path "/projects/$project/instances/$instance_name/users"
      type "operation"
    end 

    action "delete" do
      verb "DELETE"
      path "/projects/$project/instances/$instance_name/users"
      type "operation"

      field "name" do
        location "query"
      end

      field "host" do
        location "query"
      end 

      field "instance_name" do
        location "path"
      end 
    end 

    action "list" do
      verb "GET"
      path "/projects/$project/instances/$instance_name/users"
      type "users"
      output_path "items[]"
      
      field "instance_name" do
        location "path"
      end 
    end 

    action "update" do
      verb "PUT"
      path "$href"
      type "operation"

      field "host" do 
        location "query"
      end 

      field "name" do
        location "query"
      end 

      field "password" do
        location "body"
      end
    end 

    output "etag","host","instance","kind","name","project","password"

    provision "provision_resource"
    
    delete "no_operation"


  end


  type "operation" do
    href_templates "{{selfLink}}"

    output "kind","selfLink","targetProject","targetId","targetLink","name","operationType","status","user","insertTime","startTime","endTime"

    action "get" do 
      verb "GET"
      path "$href"
      type "operation"
    end

    link "targetLink" do
      url "$targetLink"
    end

    provision "no_operation"

    delete "no_operation"

  end
end 

resource_pool "cloud_sql" do
  plugin $cloud_sql
  parameter_values do
    project $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GOOGLE_SQL_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/sqlservice.admin"
      } end
      signing_key cred("GOOGLE_SQL_PLUGIN_PRIVATE_KEY")
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
  @operation = cloud_sql.$type.create($fields)
  call sys_log.detail(to_object(@operation))
  sub timeout: 5m, on_timeout: skip do
    sleep_until @operation.status == "DONE"
  end 
  if $type == "users"
    $instance_name = $fields["instance_name"]
    @resource = cloud_sql.users.empty()
  else 
    @resource = @operation.targetLink()
  end 
  call sys_log.detail(to_object(@resource))
  call stop_debugging()
end

define delete_resource(@resource) on_error: skip do
  call start_debugging()
  $raw = to_object(@resource)
  $type = $raw["type"]
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    @operation = @resource.delete()
    sub timeout: 2m, on_timeout: skip do
      sleep_until(@operation.status == "DONE")
    end
  end
  call stop_debugging()
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

