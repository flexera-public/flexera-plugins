name 'Azure DNS Record Set Test'
rs_ca_ver 20161221
short_description "Azure DNS - Record Set Test"
import "sys_log"
import "cat_spec"
import "plugins/rs_azure_dns"

parameter "subscriptionId" do
  like $rs_azure_dns.subscriptionId
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_resource_group", type: "rs_cm.resource_group" do
  cloud_href "/api/clouds/3526"
  name @@deployment.name
  description join(["container resource group for ", @@deployment.name])
end

resource "rsazdnstest_com", type: "rs_azure_dns.zone" do
  name "rsazdnstest.com"
  resource_group @@deployment.name
  location "global"
end

resource 'a_record', type: "rs_azure_dns.record_set" do
  name 'testa'
  resource_group @@deployment.name
  recordType 'a'
  zoneName @rsazdnstest_com.name
  parameters do {
    "TTL" => 60,
    "ARecords" => {
      "ipv4Address" => "4.4.4.4"
    }
  }end
end
