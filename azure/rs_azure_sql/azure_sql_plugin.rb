name 'rs_azure_sql'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure SQL Plugin"
long_description "Version: 1.1"
package "plugins/rs_azure_sql"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_sql" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "sql_server" do
    href_templates "{{type=='Microsoft.Sql/servers' && join('?',[id,'api-version=2014-04-01']) || null}}"
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
      type "sql_server"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$name?api-version=2014-04-01"
      verb "PUT"
    end

    action "show" do
      type "sql_server"
      path "$href"
      verb "GET"
    end

    action "get" do
      type "sql_server"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "sql_server"
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

    link "databases" do
      path "$id/databases?api-version=2014-04-01"
      type "databases"
      output_path "value[*]"
    end

    link "firewall_rules" do
      path "$id/firewallRules?api-version=2014-04-01"
      type "firewall_rule"
      output_path "value[*]"
    end

    link "failover_groups" do
      path "$id/failoverGroups?api-version=2015-05-01-preview"
      type "failover_group"
      output_path "value[*]"
    end

    link "elastic_pools" do
      path "$id/elasticPools?api-version=2014-04-01"
      type "elastic_pool"
      output_path "value[*]"
    end
  end

  type "databases" do
    href_templates "{{type=='Microsoft.Sql/servers/databases' && join('?',[id,'api-version=2014-04-01']) || null}}","{{value[0].type=='Microsoft.Sql/servers/databases' && map(&join('?',[id,'api-version=2014-04-01']),value) || null}}"
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
      type "databases"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/databases/$name?api-version=2014-04-01"
      verb "PUT"
    end

    action "get" do
      type "databases"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "databases"
      path "$href"
      verb "DELETE"
    end
    
    action "pause" do
      type "databases"
      path "$href/pause"
      verb "POST"
    end

    action "resume" do
      type "databases"
      path "$href/resume"
      verb "POST"
    end

    action "update" do
      type "databases"
      path "$href"
      verb "PATCH"
    end

    action "show" do
      type "databases"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/databases/$name?api-version=2014-04-01"
      verb "GET"

      field "resource_group" do
        location "path"
      end 

      field "name" do
        location "path"
      end

      field "server_name" do
        location "path"
      end
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

 type "transparent_data_encryption" do
    href_templates "{{contains(id, 'transparentDataEncryption') && join('?',[id,'api-version=2014-04-01']) || null}}"
    provision "provision_transparent_data_encryption"
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

    field "database_name" do
      type "string"
      location "path"
    end

    field "server_name" do
      type "string"
      location "path"
    end

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/databases/$database_name/transparentDataEncryption/current?api-version=2014-04-01"
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
    
    action "list_activity" do
      path "$href/operationResults"
      verb "GET"
      output_path "properties.percentComplete"
    end

    output "id","name"

    output "status" do
      body_path "properties.status"
    end
    
    output "percentComplete" do
      body_path "properties.percentComplete"
    end
  end

  type "firewall_rule" do
    href_templates "{{type=='Microsoft.Sql/servers/firewallRules' && join('?',[id,'api-version=2014-04-01']) || null}}","{{value[0].type=='Microsoft.Sql/servers/firewallRules' && map(&join('?',[id,'api-version=2014-04-01']),value) || null}}"
    provision "provision_firewall_rule"
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
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/firewallRules/$name?api-version=2014-04-01"
      verb "PUT"
    end

    action "get" do
      path "$href"
      verb "GET"
    end

    action "show" do
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end
    
    action "list" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/firewallRules?api-version=2014-04-01"
      verb "GET"
      output_path "properties.percentComplete"
    end

    output "id","name","type","location","kind"

    output "startIpAddress" do
      body_path "properties.startIpAddress"
    end
    
    output "endIpAddres" do
      body_path "properties.endIpAddress"
    end
  end

  type "elastic_pool" do
    href_templates "{{type=='Microsoft.Sql/servers/elasticPools' && join('?',[id,'api-version=2014-04-01']) || null}}","{{value[0].type=='Microsoft.Sql/servers/elasticPools' && map(&join('?',[id,'api-version=2014-04-01']),value) || null}}"
    provision "provision_elastic_pool"
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
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/elasticPools/$name?api-version=2014-04-01"
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

    action "get_database" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/elasticPools/$name/databases/$database_name?api-version=2014-04-01"
      verb "GET"
      
      field "database_name" do
        location "path"
      end
   end

    action "update" do
      path "$href"
      verb "PATCH"
    end

    action "show" do
      type "elastic_pool"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/elasticPools/$name?api-version=2014-04-01"
      verb "GET"

      field "resource_group" do
        location "path"
      end 

      field "name" do
        location "path"
      end

      field "server_name" do
        location "path"
      end
    end

    output "id","name","type","location","kind"

    output "creationDate" do
      body_path "properties.creationDate"
    end

    output "edition" do
      body_path "properties.edition"
    end

    output "state" do
      body_path "properties.state"
    end

    output "dtu" do
      body_path "properties.dtu"
    end

    output "databaseDtuMin" do
      body_path "properties.databaseDtuMin"
    end

    output "databaseDtuMax" do
      body_path "properties.databaseDtuMax"
    end

    output "storageMB" do
      body_path "properties.storageMB"
    end
  end

  type "failover_group" do
    href_templates "{{type=='Microsoft.Sql/servers/failoverGroups' && join('?',[id,'api-version=2015-05-01-preview']) || null}}","{{value[0].type=='Microsoft.Sql/servers/failoverGroups' && map(&join('?',[id,'api-version=2015-05-01-preview']),value) || null}}"
    provision "provision_failover_group"
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
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/failoverGroups/$name?api-version=2015-05-01-preview"
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
  end

  type "security_policy" do
    href_templates "{{type=='Microsoft.Sql/servers/databases/securityAlertPolicies' && join('?',[id,'api-version=2014-04-01']) || null}}"
    provision "provision_security_policy"
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

    field "database_name" do
      type "string"
      location "path"
    end

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/databases/$database_name/securityAlertPolicies/$name?api-version=2014-04-01"
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

    output "state" do
      body_path "properties.state"
    end

    output "emailAccountAdmins" do
      body_path "properties.emailAccountAdmins"
    end

    output "emailAddresses" do
      body_path "properties.emailAddresses"
    end

    output "disabledAlerts" do
      body_path "properties.disabledAlerts"
    end

    output "retentionDays" do
      body_path "properties.retentionDays"
    end

    output "storageAccountAccessKey" do
      body_path "properties.storageAccountAccessKey"
    end

    output "storageEndpoint" do
      body_path "properties.storageEndpoint"
    end

    output "useServerDefault" do
      body_path "properties.useServerDefault"
    end
  end

  type "auditing_policy" do
    href_templates "{{type=='Microsoft.Sql/servers/databases/auditingSettings' && join('?',[id,'api-version=2015-05-01-preview']) || null}}"
    provision "provision_auditing_policy"
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

    field "database_name" do
      type "string"
      location "path"
    end

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Sql/servers/$server_name/databases/$database_name/auditingSettings/$name?api-version=2015-05-01-preview"
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

    output "state" do
      body_path "properties.state"
    end

    output "storageEndpoint" do
      body_path "properties.storageEndpoint"
    end

    output "storageAccountAccessKey" do
      body_path "properties.storageAccountAccessKey"
    end

    output "retentionDays" do
      body_path "properties.retentionDays"
    end

    output "storageAccountSubscriptionId" do
      body_path "properties.storageAccountSubscriptionId"
    end

    output "isStorageSecondaryKeyInUse" do
      body_path "properties.isStorageSecondaryKeyInUse"
    end

    output "auditActionsAndGroups" do
      body_path "properties.auditActionsAndGroups"
    end
  end
end

resource_pool "rs_azure_sql" do
    plugin $rs_azure_sql
    parameter_values do
      subscription_id $subscription_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/AZURE_TENANT_ID/oauth2/token"
      grant type: "client_credentials" do
        client_id cred("AZURE_APPLICATION_ID")
        client_secret cred("AZURE_APPLICATION_KEY")
        additional_params do {
          "resource" => "https://management.azure.com/"     
        } end
      end
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
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show()
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
    @operation = rs_azure_sql.$type.create($fields)
    call sys_log.detail($operation)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    $name = $fields["name"]
    $server_name = $fields["server_name"]
    $resource_group = $fields["resource_group"]
    call sys_log.detail("entering check for database created")
    sub on_error: retry, timeout: 60m do
      call sys_log.detail("sleeping 10")
      sleep(10)
      @new_resource = @operation.show(name: $name, server_name: $server_name, resource_group: $resource_group )
    end
    @new_resource = @operation.show(name: $name, server_name: $server_name, resource_group: $resource_group )
    $status = @new_resource.status
    call sys_log.detail("Checking that database state is online")
    sub on_error: skip, timeout: 60m do
      while $status != "Online" do
        $status = @operation.show(name: $name, server_name: $server_name, resource_group: $resource_group).status
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        call start_debugging()
        sleep(10)
      end
    end
    @resource = @new_resource
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define provision_transparent_data_encryption(@declaration) return @resource do
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
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_firewall_rule(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define provision_elastic_pool(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    $name = $fields["name"]
    $server_name = $fields["server_name"]
    $resource_group = $fields["resource_group"]
    call sys_log.detail("entering check for elastic pool created")
    sub on_error: retry, timeout: 60m do
      call sys_log.detail("sleeping 10")
      sleep(10)
      @new_resource = @operation.show(name: $name, server_name: $server_name, resource_group: $resource_group )
    end
    @new_resource = @operation.show(name: $name, server_name: $server_name, resource_group: $resource_group )
    $status = @new_resource.state
    call sys_log.detail("Checking that database state is online")
    sub on_error: skip, timeout: 60m do
      while $status != "Ready" do
        $status = @operation.show(name: $name, server_name: $server_name, resource_group: $resource_group).state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        call start_debugging()
        sleep(10)
      end
    end
    @resource = @new_resource
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define provision_failover_group(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging() 
    call sys_log.detail(to_object(@resource))
  end
end

define provision_security_policy(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    $status = @resource.state
    call sys_log.detail(join(["Status: ", $status]))
    call stop_debugging()
    sub on_error: skip, timeout: 2m do
      while $status != "Enabled" do
        call start_debugging()
        $status = @resource.state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    call stop_debugging() 
    call sys_log.detail(to_object(@resource))
  end
end

define provision_auditing_policy(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_sql.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    $status = @resource.state
    call sys_log.detail(join(["Status: ", $status]))
    call stop_debugging()
    sub on_error: skip, timeout: 2m do
      while $status != "Enabled" do
        call start_debugging()
        $status = @resource.state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    call stop_debugging() 
    call sys_log.detail(to_object(@resource))
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  sub on_error: skip do
    @declaration.destroy()
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
