name 'rs_azure_sql'
type 'plugin'
rs_ca_ver 20161221
short_description "Azure SQL Plugin"
package "plugins/rs_azure_sql"
import "sys_log"

parameter "p_server_name" do
  type  "string"
  label "Server Name"
end

parameter "p_resource_group_name" do
  type  "string"
  label "Resource Group Name"
end

parameter "p_subscription_id" do
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

  type "server" do
    href_templates "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Sql/servers/$server_name"
    provision "provision_resource"
    delete    "delete_resource"

    field "server_name" do
      alias_for "serverName"
      type      "string"
      location  "path"
      required true
    end

    field "resource_group_name" do
      alias_for "resourceGroupName"
      type      "string"
      location  "path"
      required true
    end

    field "subscription_id" do
      alias_for "subscriptionId"
      type      "string"
      location  "path"
      required true
    end

    field "version" do
      alias_for "parameters.parameters.properties.version"
      type "string"
      location "body"
    end

    field "administrator_login" do
      alias_for "parameters.parameters.properties.administratorLogin"
      type "string"
      location "body"
    end

    field "administrator_login_password" do
      alias_for "parameters.parameters.properties.administratorLoginPassword"
      type "string"
      location "body"
    end

    field "location" do
      alias_for "parameters.parameters.location"
      type "string"
      location "body"
    end

    action "create" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Sql/servers/$server_name"
      verb "POST"
    end

    action "get" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Sql/servers/$server_name"
      verb "GET"
    end

    action "destroy" do
      path "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Sql/servers/$server_name"
      verb "DELETE"
    end

    output_path "responses.*.body"

    provision "provision_resource"
    delete "delete_resource"
  end
end

resource_pool "rs_azure_sql" do
    plugin $rs_azure_sql
    parameter_values do
      server_name $p_server_name
      resource_group_name $p_resource_group_name
      subscription_id $p_subscription_id
    end

    auth "azure_auth", type: "oauth2" do
      token_url "https://login.microsoftonline.com/09b8fec1-4b8d-48dd-8afa-5c1a775ea0f2/oauth2/token"
      grant type: "client_credentials" do
        client_id cred("AZURE_APPLICATION_ID")
        client_secret cred("AZURE_APPLICATION_KEY")
      end
    end
end

define provision_resource(@declaration) return @resource do
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

resource "sql_server", type: "rs_azure_sql.server" do
  server_name join(["rs-test-sql", last(split(@@deployment.href, "/"))])
  resource_group_name "DF-Testing"
  subscription_id "8beb7791-9302-4ae4-97b4-afd482aadc59"
  version "2.0"
  administrator_login "admin"
  administrator_login_password "admin"
  location "Central US"
end