name 'SQL Test CAT'
rs_ca_ver 20161221
short_description "Azure SQL Database Service - Test CAT"
import "sys_log"
import "plugins/rs_azure_sql"

parameter "subscription_id" do
  like $rs_azure_sql.subscription_id
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

output "failover_groups" do
  label "failover_groups"
  category "Databases"
  default_value $failover_groups_link_output
  description "failover_groups"
end

output "elastic_pools" do
  label "elastic_pools"
  category "Databases"
  default_value $elastic_pools_link_output
  description "elastic_pools"
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
      "administratorLogin" =>"superdbadmin",
      "administratorLoginPassword" => "RightScale2017!"
  } end
end

resource "database", type: "rs_azure_sql.databases" do
  name "sample-database"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

resource "transparent_data_encryption", type: "rs_azure_sql.transparent_data_encryption" do
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "status" => "Disabled"
  } end
end

resource "firewall_rule", type: "rs_azure_sql.firewall_rule" do
  name "sample-firewall-rule"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  properties do {
    "startIpAddress" => "0.0.0.1",
    "endIpAddress" => "0.0.0.1"
  } end
end

resource "elastic_pool", type: "rs_azure_sql.elastic_pool" do
  name "sample-elastic-pool"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

resource "auditing_policy", type: "rs_azure_sql.auditing_policy" do
  name "sample-auditing-policy"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "state" => "Enabled",
    "storageAccountAccessKey" => cred("storageAccountAccessKey"),
    "storageEndpoint" => cred("storageEndpoint")
  } end
end

resource "security_policy", type: "rs_azure_sql.security_policy" do
  name "sample-security-policy"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "state" => "Enabled",
    "storageAccountAccessKey" => cred("storageAccountAccessKey"),
    "storageEndpoint" => cred("storageEndpoint")
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
  $databases => $db_link_output,
  $firewall_rules => $firewall_rules_link_output,
  $failover_groups => $failover_groups_link_output,
  $elastic_pools => $elastic_pools_link_output
 } end
end

define launch_handler(@sql_server,@database,@transparent_data_encryption,@firewall_rule,@elastic_pool,@auditing_policy,@security_policy) return @databases,$db_link_output,$firewall_rules_link_output,$failover_groups_link_output, $elastic_pools_link_output do
  provision(@sql_server)
  provision(@database)
  provision(@transparent_data_encryption)
  provision(@firewall_rule)
  provision(@elastic_pool)
  provision(@auditing_policy)
  provision(@security_policy)
  call start_debugging()
  sub on_error: skip, timeout: 2m do
    call sys_log.detail("getting database link")
    @databases = @sql_server.databases()
    $db_link_output = to_s(to_object(@databases))
    call sys_log.detail("getting firewall link")
    @firewall_rules = @sql_server.firewall_rules() 
    $firewall_rules_link_output  = to_s(to_object(@firewall_rules))
    call sys_log.detail("getting failover link")
    @failover_groups = @sql_server.failover_groups()
    $failover_groups_link_output = to_s(to_object(@failover_groups))
    call sys_log.detail("getting elastic pool link")
    @elastic_pools = @sql_server.elastic_pools()
    $elastic_pools_link_output = to_s(to_object(@elastic_pools))
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