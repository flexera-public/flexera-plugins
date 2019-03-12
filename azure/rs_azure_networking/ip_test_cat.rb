name 'Azure Ip Address - Test CAT'
rs_ca_ver 20161221
short_description "Azure Ip Address - Test CAT"
import "sys_log"
import "plugins/rs_azure_networking_plugin"

parameter "subscription_id" do
  like $rs_azure_networking_plugin.subscription_id
end

output "ip1" do
  label "New IP"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "ip", type: "rs_azure_ip.public_ip_address" do
  name @@deployment.name
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
  output_mappings do {
    $ip1 => $ip
  } end
end

define launch_handler(@ip,$subscription_id) return @ip,$ip do
  provision(@ip)
  $ip = @ip.properties.ipAddress
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
