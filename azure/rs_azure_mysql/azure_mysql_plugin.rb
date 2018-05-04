name 'rs_azure_mysql'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure MySQL Plugin"
long_description "Version: 1.1"
package "plugins/rs_azure_mysql"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

plugin "rs_azure_mysql" do
  endpoint do
    default_host "https://management.azure.com/"
    default_scheme "https"
    query do {
      'api-version' =>  '2017-04-30-preview'
    } end
  end

  parameter "subscription_id" do
    type  "string"
    label "subscription_id"
  end

  type "mysql_server" do
    href_templates "{{type=='Microsoft.DBforMySQL/servers' && id || null}}"
    provision "provision_server"
    delete    "delete_resource"

    field "properties" do
      type "composite"
      location "body"
    end

    field "sku" do
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
      type "mysql_server"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DBforMySQL/servers/$name"
      verb "PUT"
    end

    action "show" do
      type "mysql_server"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DBforMySQL/servers/$name"
      verb "GET"

      field "resource_group" do
        location "path"
      end

      field "name" do
        location "path"
      end
    end

    action "get" do
      type "mysql_server"
      path "$href"
      verb "GET"
    end

    action "destroy" do
      type "mysql_server"
      path "$href"
      verb "DELETE"
    end

    output "id","name","type","location","tags","sku","properties"

    output "state" do
      body_path "properties.userVisibleState"
    end

    output "fullyQualifiedDomainName" do
      body_path "properties.fullyQualifiedDomainName"
    end

    output "administratorLogin" do
      body_path "properties.administratorLogin"
    end

    output "administratorLoginPassword" do
      body_path "properties.administratorLoginPassword"
    end

    output "sslEnforcement" do
      body_path "properties.sslEnforcement"
    end

    output "userVisibleState" do
      body_path "properties.userVisibleState"
    end

    output "version" do
      body_path "properties.version"
    end

    link "databases" do
      path "$id/databases"
      type "databases"
      output_path "value[*]"
    end

    link "firewall_rules" do
      path "$id/firewallRules"
      type "firewall_rule"
      output_path "value[*]"
    end

  end

  type "databases" do
    href_templates "{{type=='Microsoft.DBforMySQL/servers/databases' && id || null}}","{{value[0].type=='Microsoft.DBforMySQL/servers/databases' && id|| null}}"
    provision "provision_database"
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
      type "databases"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DBforMySQL/servers/$server_name/databases/$name"
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

    action "update" do
      type "databases"
      path "$href"
      verb "PUT"
    end

    action "show" do
      type "databases"
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DBforMySQL/servers/$server_name/databases/$name"
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

    output "id","name","type"

    output "collation" do
      body_path "properties.collation"
    end

    output "charset" do
      body_path "properties.charset"
    end

  end

  type "firewall_rule" do
    href_templates "{{type=='Microsoft.DBforMySQL/servers/firewallRules' && id || null}}","{{value[0].type=='Microsoft.DBforMySQL/servers/firewallRules' && id || null}}"
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
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DBforMySQL/servers/$server_name/firewallRules/$name"
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
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.DBforMySQL/servers/$server_name/firewallRules"
      verb "GET"
      output_path "value[*]"
    end

    output "id","name","type"

    output "startIpAddress" do
      body_path "properties.startIpAddress"
    end

    output "endIpAddres" do
      body_path "properties.endIpAddress"
    end
  end
end

resource_pool "rs_azure_mysql" do
    plugin $rs_azure_mysql
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

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_mysql.$type.create($fields)
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
    @operation = rs_azure_mysql.$type.create($fields)
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
      while $status != "Ready" do
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

define provision_database(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_mysql.$type.create($fields)
    call sys_log.detail($operation)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    $name = $fields["name"]
    $server_name = $fields["server_name"]
    $resource_group = $fields["resource_group"]
    call sys_log.detail("entering check for database created")
    $attempts = 0
    sub on_error: handle_retries($attempts), timeout: 60m do
      $attempts = $attempts + 1
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

define provision_firewall_rule(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_mysql.$type.create($fields)
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