name 'SQL Test CAT'
rs_ca_ver 20161221
short_description "Azure SQL Database Service - Test CAT"
import "plugins/rs_azure_sql"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
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
    "storageAccountAccessKey" => "X0Z/nzf9d5u0GVgLwNI3uOjO+dtETcH9AMOOQKZ8Ikmuw4i8eiiNsKd4QPK4QKDXENIyNKenXn3GE3WOhmVJPQ==",
    "storageEndpoint" => "https://dftestingdiag134.blob.core.windows.net/"
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
    "storageAccountAccessKey" => "X0Z/nzf9d5u0GVgLwNI3uOjO+dtETcH9AMOOQKZ8Ikmuw4i8eiiNsKd4QPK4QKDXENIyNKenXn3GE3WOhmVJPQ==",
    "storageEndpoint" => "https://dftestingdiag134.blob.core.windows.net/"
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler($subscription_id) return $subscription_id do
  $subscription_id=$subscription_id
end