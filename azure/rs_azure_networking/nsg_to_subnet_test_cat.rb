name 'Azure Add NSG to Subnet Test'
rs_ca_ver 20161221
short_description 'Azure Add NSG to Subnet - Test CAT'

import 'sys_log'
import 'plugins/rs_azure_networking'

parameter 'subscription_id' do
  like $rs_azure_networking.subscription_id
end

permission 'read_creds' do
  actions   'rs_cm.show_sensitive','rs_cm.index_sensitive'
  resources 'rs_cm.credentials'
end

resource 'network1', type: 'network' do
  name          join(["Network-",last(split(@@deployment.href,"/"))])
  description	  join(["Network-",last(split(@@deployment.href,"/"))])
  cloud         'AzureRM Central US'
  cidr_block    '10.1.0.0/16'
end

resource 'subnet1', type: 'subnet' do
  name        join(["Subnet-",last(split(@@deployment.href,"/"))])
  description join(["Subnet-",last(split(@@deployment.href,"/"))])
  network     @network1
  cloud       'AzureRM Central US'
  cidr_block  '10.1.0.0/24'
end

resource "nsg1", type: "security_group" do
  name        join(["NSG-",last(split(@@deployment.href,"/"))])
  description join(["NSG-",last(split(@@deployment.href,"/"))])
  cloud       'AzureRM Central US'
  network     @network1
end

operation "launch" do
  label         "Launch"
  description   "Launches the CloudApp"
  definition    "launch_me"
end

define launch_me(@network1, @subnet1, @nsg1, $subscription_id) return @network1, @subnet1, @nsg1 do
  
  provision(@network1)
  $resource_group_name = @@deployment.resource_group().name

  provision(@subnet1)
  provision(@nsg1)
  $nsg_resource_path = '/subscriptions/' + $subscription_id + '/resourceGroups/' + $resource_group_name + '/providers/Microsoft.Network/networkSecurityGroups/' + @nsg1.name
  sub on_error: stop_debugging() do
    call start_debugging()
    @subnet = rs_azure_networking.subnet.get(resource_group: $resource_group_name, vnet_name: @network1.name, name: @subnet1.name)
    call stop_debugging()
    call sys_log.detail(to_s(@subnet))
    call start_debugging()
    $object = to_object(@subnet)
    call sys_log.detail("object:" + to_s($object)+"\n")
    $fields = $object["details"]
    call sys_log.detail("fields:" + to_s($fields) + "\n")
    $subnet = $fields[0]
    call sys_log.detail("subnet:" + to_s($subnet))
    $subnet["properties"]["networkSecurityGroup"] = {}
    $subnet["properties"]["networkSecurityGroup"]["id"] = $nsg_resource_path
    call sys_log.detail("updated_vnet:" + to_s($subnet))
    call start_debugging()
    @updated_subnet = @subnet.update($subnet)
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