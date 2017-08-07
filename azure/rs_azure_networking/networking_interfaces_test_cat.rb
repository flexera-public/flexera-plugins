name 'Azure NIC Test CAT'
rs_ca_ver 20161221
short_description "Azure Compute - Test CAT"
import "sys_log"
import "plugins/rs_azure_networking_interfaces"

parameter "subscription_id" do
  like $rs_azure_networking_interfaces.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler() return @my_nic do
  sub on_error: stop_debugging() do
    call start_debugging()
    @my_nic = rs_azure_networking_interfaces.interface.show(resource_group: 'rs-default-centralus', name: 'azure-default-cc3cbb6c7')
    call stop_debugging()
    $object = to_object(@my_nic)
    call sys_log.detail("object:" + to_s($object)+"\n")
    $fields = $object["details"]
    call sys_log.detail("fields:" + to_s($fields) + "\n")
    $nic = $fields[0]
    call sys_log.detail("nic:" + to_s($nic))
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"] = []
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0] = {}
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0]["id"] = "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/my-pub-lb-979117003/backendAddressPools/pool1"
    call sys_log.detail("updated_nic:" + to_s($nic))
    call start_debugging()
    @updated_nic = @my_nic.update($nic)
    call stop_debugging()
  end
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