name 'rs_azure_sql'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure SQL Plugin"
package "plugins/rs_azure_sql"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

plugin "rs_azure_sql" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      "api-version" => "2014-04-01"
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end
  
  type "az_operation" do
    href_templates "{{operation=='CreateLogicalDatabase'}}"
  end

  type "sql_server" do
    href_templates "{{type=='Microsoft.Sql/servers' && id}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "location" do
      type "string"
      location "body"
    end

    field "resource_group" do
      type "string"
      location "path"
    end 

    field "name" do
      type "string"
      location "path"
    end

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$name"
      verb "PUT"
    end

    action "get" do
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    output "id","name","type","location","kind"

    output "fullyQualifiedDomainName" do
      body_path "properties.fullyQualifiedDomainName"
    end

    output "administratorLogin" do
      body_path "properties.administratorLogin"
    end

    output "administratorLoginPassword" do
      body_path "properties.administratorLoginPassword"
    end

    output "externalAdministratorLogin" do
      body_path "properties.externalAdministratorLogin"
    end

    output "externalAdministratorSid" do
      body_path "properties.externalAdministratorSid"
    end

    output "version" do
      body_path "properties.version"
    end

    output "state" do
      body_path "properties.state"
    end

    #link "databases" do
    #  path "$href/databases"
    #  type "databases"
    #end
  end

  type "databases" do
    href_templates "{{type=='Microsoft.Sql/servers/databases') && id}}"
    #href_templates "{{id}}"
    provision "provision_database"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "location" do
      type "string"
      location "body"
    end

    field "resource_group" do
      type "string"
      location "path"
    end 

    field "name" do
      type "string"
      location "path"
    end

    field "server_name" do
      type "string"
      location "path"
    end

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/databases/$name"
      verb "PUT"
    end

    action "get" do
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end
    
    action "pause" do
      path "$href/pause"
      verb "POST"
    end

    action "resume" do
      path "$href/resume"
      verb "POST"
    end

    action "update" do
      path "$href"
      verb "PATCH"
    end

    output "id","name","type","location","kind"

    output "edition" do
      body_path "properties.edition"
    end

    output "status" do
      body_path "properties.status"
    end

    output "serviceLevelObjective" do
      body_path "properties.serviceLevelObjective"
    end

    output "collation" do
      body_path "properties.collation"
    end

    output "creationDate" do
      body_path "properties.creationDate"
    end

    output "maxSizeBytes" do
      body_path "properties.maxSizeBytes"
    end

    output "currentServiceObjectiveId" do
      body_path "properties.currentServiceObjectiveId"
    end

    output "requestedServiceObjectiveId" do
      body_path "properties.requestedServiceObjectiveId"
    end

    output "requestedServiceObjectiveName" do
      body_path "properties.requestedServiceObjectiveName"
    end

    output "sampleName" do
      body_path "properties.sampleName"
    end

    output "defaultSecondaryLocation" do
      body_path "properties.defaultSecondaryLocation"
    end

    output "earliestRestoreDate" do
      body_path "properties.earliestRestoreDate"
    end

    output "elasticPoolName" do
      body_path "properties.elasticPoolName"
    end

    output "containmentState" do
      body_path "properties.containmentState"
    end

    output "readScale" do
      body_path "properties.readScale"
    end

    output "failoverGroupId" do
      body_path "properties.failoverGroupId"
    end
  end

#  type "firewall_rule" do
#    href_templates "{{type=='Microsoft.Sql/servers/firewallRules' && id}}"
#    provision "provision_firewall_rule"
#    delete    "delete_resource"
#
#    field "properties" do
#      type "composite"
#      location "body"
#    end
#
#    field "location" do
#      type "string"
#      location "body"
#    end

#    field "resource_group" do
#      type "string"
#      location "path"
#    end 

#    field "name" do
#      type "string"
#      location "path"
#    end

#    field "server_name" do
#      type "string"
#      location "path"
#    end

#    action "create" do
#      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/firewallRules/$name"
#      verb "PUT"
#    end

#    action "get" do
#      path "$href"
#      verb "GET"
#    end

#    action "destroy" do
#      path "$href"
#      verb "DELETE"
#    end
    
#    action "list" do
#      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/firewallRules"
#      verb "GET"
#      output_path "properties.percentComplete"
#    end

#    output "id","name","type","location","kind"

#    output "startIpAddress" do
#      body_path "properties.startIpAddress"
#    end
    
#    output "endIpAddres" do
#      body_path "properties.endIpAddress"
#    end
#  end

#  type "elastic_pool" do
#    href_templates "{{type=='Microsoft.Sql/servers/elasticPools' && id}}"
#    provision "provision_elastic_pool"
#    delete    "delete_resource"

#    field "properties" do
#      type "composite"
#      location "body"
#    end

#    field "location" do
#      type "string"
#      location "body"
#    end

#    field "resource_group" do
#      type "string"
#      location "path"
#    end 

#    field "name" do
#      type "string"
#      location "path"
#    end

#    field "server_name" do
#      type "string"
#      location "path"
#    end

#    action "create" do
#      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/elasticPools/$name"
#      verb "PUT"
#    end

#    action "get" do
#      path "$href"
#      verb "GET"
#    end

#    action "destroy" do
#      path "$href"
#      verb "DELETE"
#    end

#    action "get_database" do
#      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/elasticPools/$name/databases/$database_name"
#      verb "GET"
##      
#      field "database_name" do
#        type "string"
#        location "path"
#      end
#   end

#    action "update" do
#      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/elasticPools/$name"
#      verb "PATCH"
#    end

#    output "id","name","type","location","kind"

#    output "creationDate" do
#      body_path "properties.creationDate"
#    end

#    output "edition" do
#      body_path "properties.edition"
#    end

#    output "state" do
#      body_path "properties.state"
#    end

#    output "dtu" do
#      body_path "properties.dtu"
#    end

#    output "databaseDtuMin" do
#      body_path "properties.databaseDtuMin"
#    end

#    output "databaseDtuMax" do
#      body_path "properties.databaseDtuMax"
#    end

#    output "storageMB" do
#      body_path "properties.storageMB"
#    end
#  end
end

resource_pool "rs_azure_sql" do
    plugin $rs_azure_sql
    parameter_values do
      subscription_id $subscription_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/09b8fec1-4b8d-48dd-8afa-5c1a775ea0f2/oauth2/token"
      grant type: "client_credentials" do
        client_id cred("AZURE_APPLICATION_ID")
        client_secret cred("AZURE_APPLICATION_KEY")
        additional_params do {
          "resource" => "https://management.azure.com/"     
        } end
      end
    end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    $status = @resource.state
    sub on_error: skip, timeout: 60m do
      while $status != "Ready" do
        $status = @resource.state
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_database(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    $operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail($operation)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    $status = rs_azure_sql.$type.get($operation).status
    sub on_error: skip, timeout: 60m do
      while $status != "Online" do
        $status = @operation.get().status
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end
    call start_debugging()
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_transparentdataencryption(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    $status = @resource.status
    sub on_error: skip, timeout: 60m do
      while $status != "Online" do
        $status = @resource.status
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_firewall_rule(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_elastic_pool(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    $status = @resource.state
    sub on_error: skip, timeout: 60m do
      while $status != "Ready" do
        $status = @resource.state
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  @declaration.destroy()
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

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "sql_server", type: "rs_azure_sql.sql_server" do
  name join(["my-sql-server-", last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  location "Central US"
  properties do {
      "version" => "12.0",
      "administratorLogin" =>"frankel",
      "administratorLoginPassword" => "RightScale2017"
  } end
end

resource "databases", type: "rs_azure_sql.databases" do
  name "sample-database"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

#resource "firewall_rule", type: "rs_azure_sql.firewall_rule" do
#  name "api-example-dns-rule"
#  resource_group "DF-Testing"
#  location "Central US"
#  server_name @sql_server.name
#  properties do {
#    "startIpAddress" => "0.0.0.1",
#    "endIpAddress" => "0.0.0.1"
#  } end
#end