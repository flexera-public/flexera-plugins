name 'PGSQL Test CAT'
rs_ca_ver 20161221
short_description "Azure PostgresSQL Database Service - Test CAT"
import "sys_log"
import "plugins/rs_azure_pgsql"

parameter "subscription_id" do
  like $rs_azure_pgsql.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
end

output "databases" do
  label "Databases"
  category "Databases"
  default_value $db_link_output
  description "Databases"
end

output "firewall_rules" do
  label "firewall_rules"
  category "Databases"
  default_value $firewall_rules_link_output
  description "firewall_rules"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "sql_server", type: "rs_azure_pgsql.pgsql_server" do
  name join(["my-sql-server-", last(split(@@deployment.href, "/"))])
  resource_group "CCtestresourcegroup"
  location "northcentralus"
  properties do {
    "administratorLogin" => "cloudsa",
    "administratorLoginPassword" => "RightScale2017",
    "storageMB" => 51200,
    "sslEnforcement" => "Enabled",
    "createMode" => "Default"
  } end
  sku do {
    "name" => "PGSQLB100",
    "tier" => "Basic",
    "capacity" => 100
  } end
  tags do {
    "ElasticServer" => "1"
  } end
end

resource "firewall_rule", type: "rs_azure_pgsql.firewall_rule" do
  name "sample-firewall-rule"
  resource_group "CCtestresourcegroup"
  location "northcentralus"
  server_name @sql_server.name
  properties do {
    "startIpAddress" => "0.0.0.1",
    "endIpAddress" => "0.0.0.1"
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
  $databases => $db_link_output,
  $firewall_rules => $firewall_rules_link_output
 } end
end

define launch_handler(@sql_server,@firewall_rule) return @databases,$db_link_output,$firewall_rules_link_output do
  call start_debugging()
  provision(@sql_server)
  provision(@firewall_rule)
  sub on_error: skip, timeout: 2m do
    call sys_log.detail("getting database link")
    @databases = @sql_server.databases()
    $db_link_output = to_s(to_object(@databases))
    call sys_log.detail("getting firewall link")
    @firewall_rules = @sql_server.firewall_rules() 
    $firewall_rules_link_output  = to_s(to_object(@firewall_rules))
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
