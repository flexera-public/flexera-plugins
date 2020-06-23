name 'PGSQL Test CAT'
rs_ca_ver 20161221
short_description "Azure PostgresSQL Database Service - Test CAT"
import "sys_log"
import "plugins/rs_azure_pgsql"
import "azure/cloud_parameters"

parameter "tenant_id" do
  like $cloud_parameters.tenant_id
  operations "launch"
end

parameter "subscription_id" do
  like $cloud_parameters.subscription_id
  operations "launch"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "sql_server", type: "rs_azure_pgsql.pgsql_server" do
  name join(["my-sql-server-", last(split(@@deployment.href, "/"))])
  resource_group "AADDS"
  location "eastus"
  properties do {
    "administratorLogin" => "cloudsa",
    "administratorLoginPassword" => "RightScale2017",
    "sslEnforcement" => "Enabled",
    "version" => "10",
    "minimalTlsVersion" => "TLSEnforcementDisabled",
    "infrastructureEncryption" => "Disabled",
    "publicNetworkAccess" => "Enabled",
    "storageProfile" => {
      "storageMB" => "51200",
      "backupRetentionDays" => "7",
      "geoRedundantBackup" => "Disabled",
      "storageAutogrow" => "Enabled"
    }
  } end
  sku do {
    "name" => "B_Gen5_1",
    "tier" => "Basic",
    "family" => "Gen5",
    "capacity" => "1"
  } end
  tags do {
    "ElasticServer" => "1"
  } end
end
