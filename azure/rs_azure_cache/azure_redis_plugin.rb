name 'rs_azure_redis'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure Redis Plugin"
long_description "Version: 1.0"
package "plugins/rs_azure_redis"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_redis" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2016-04-01'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "cache" do
    href_templates "{{type=='Microsoft.Cache/Redis' && id || null}}"
    provision "provision_server"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "tags" do
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
      type "cache"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Cache/Redis/$name"
      verb "PUT"
    end

    action "show" do
      type "cache"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Cache/Redis/$name"
      verb "GET"
      
      field "resource_group" do
        location "path"
      end 

      field "name" do
        location "path"
      end
    end

    action "update" do
      type "cache"
      path "$href"
      verb "PUT"
    end

    action "get" do
      type "cache"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "cache"
      path "$href"
      verb "DELETE"
    end

    action "import" do
      type "cache"
      path "$href/import"
      verb "POST"
    end

    action "export" do
      type "cache"
      path "$href/export"
      verb "POST"
    end

    action "reboot" do
      type "cache"
      path "$href/forceReboot"
      verb "POST"
    end

    action "listkeys" do
      type "cache"
      path "$href/listKeys"
      verb "POST"
    end

    action "regeneratekey" do
      type "cache"
      path "$href/regenerateKey"
      verb "POST"
    end

    output "id","name","type","location","tags","properties"

    output "state" do
      body_path "properties.provisioningState"
    end

    output "provisioningState" do
      body_path "properties.provisioningState"
    end

    output "redisVersion" do
      body_path "properties.redisVersion"
    end

    output "primaryKey" do
      body_path "properties.accessKeys.primaryKey"
    end

    output "secondaryKey" do
      body_path "properties.accessKeys.secondaryKey"
    end

    output "sku" do
      body_path "properties.sku"
    end

    output "enableNonSslPort" do
      body_path "properties.enableNonSslPort"
    end

    output "redisConfiguration" do
      body_path "properties.redisConfiguration"
    end

    output "hostName" do
      body_path "properties.hostName"
    end

    output "port" do
      body_path "properties.port"
    end

    output "sslPort" do
      body_path "properties.sslPort"
    end

    link "firewall_rules" do
      path "$id/firewallRules"
      type "firewall_rule"
      output_path "value[*]"
    end
  end

  type "firewall_rule" do
    href_templates "{{type=='Microsoft.Cache/redis/firewallRules' && id || null}}","{{value[0].type=='Microsoft.Cache/Redis/firewallRules' && value[*].id || null}}","{{type=='Microsoft.Cache/Redis/firewallRules' && id || null}}"
    provision "provision_firewall_rule"
    delete    "delete_resource"

    field "properties" do
      type "composite"
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
      type "firewall_rule"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Cache/Redis/$server_name/firewallRules/$name"
      verb "PUT"
    end

    action "get" do
      type "firewall_rule"
      path "$href"
      verb "GET"
    end

    action "show" do
      type "firewall_rule"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end
    
    action "list" do
      type "firewall_rule"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Cache/Redis/$server_name/firewallRules"
      verb "GET"
      output_path "value[*]"
    end

    output "id","name","type"

    output "startIP" do
      body_path "properties.startIP"
    end
    
    output "endIP" do
      body_path "properties.endIP"
    end
  end

    type "patch_schedule" do
    href_templates "{{type=='Microsoft.Cache/Redis/patchSchedules' && id || null}}","{{type=='Microsoft.Cache/Redis/PatchSchedules' && id || null}}"
    provision "provision_patch_schedule"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "resource_group" do
      type "string"
      location "path"
    end

    field "server_name" do
      type "string"
      location "path"
    end

    action "create" do
      type "patch_schedule"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Cache/Redis/$server_name/patchSchedules/default"
      verb "PUT"
    end

    action "get" do
      type "patch_schedule"
      path "$href"
      verb "GET"
    end

    action "show" do
      type "patch_schedule"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

    output "id","name","type","location","properties"
    output "scheduleEntries" do
      body_path "properties.scheduleEntries"
    end
  end
end

resource_pool "rs_azure_redis" do
    plugin $rs_azure_redis
    parameter_values do
      subscription_id $subscription_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"
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

define provision_server(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_redis.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    call stop_debugging()
    call sys_log.detail("entering check for database created")
    $attempts = 0
    sub on_error: handle_retries($attempts), timeout: 60m do
      $attempts = $attempts + 1
      call sys_log.detail("sleeping 10, db server not created")
      sleep(10)
      call start_debugging()
      @new_resource = @operation.show(name: $name, resource_group: $resource_group )
      call stop_debugging()
    end
    call start_debugging()
    @new_resource = @operation.show(name: $name, resource_group: $resource_group)
    $status = @new_resource.state
    call sys_log.detail("Checking that database state is online")
    sub on_error: skip, timeout: 60m do
      while $status != "Succeeded" do
        $status = @new_resource.state
        call stop_debugging()
        call sys_log.detail(join(["Status: ", $status]))
        call start_debugging()
        sleep(10)
      end
    end
    @resource = @new_resource
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define handle_retries($attempts) do
  if $attempts <= 36
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
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
    @operation = rs_azure_redis.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define provision_patch_schedule(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_redis.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  sub on_error: stop_debugging() do
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
