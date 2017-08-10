name 'Azure DNS Zone Test'
rs_ca_ver 20161221
short_description "Azure DNS - Zone Test"
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
