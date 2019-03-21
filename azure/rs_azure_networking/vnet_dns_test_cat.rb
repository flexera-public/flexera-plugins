name 'Azure Add vNet DNS Test'
rs_ca_ver 20161221
short_description 'Azure Add vNet DNS - Test CAT'

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

operation "launch" do
  label         "Launch"
  description   "Launches the CloudApp"
  definition    "launch_me"
end

define launch_me(@network1) do
  provision(@network1)
  #sleep(120)
  $resource_group_name = @network1.deployment().resource_group().name
  $dns1 = "4.4.4.4"
  $dns2 = "4.4.8.8"
  $tags = {
    'cost_center': '12345',
    'project': 'plugins',
    'save': 'true'
  }
  sub on_error: stop_debugging() do
    call start_debugging()
    @vnet = rs_azure_networking.network.get(resource_group: $resource_group_name, name: @network1.name)
    call stop_debugging()
    call sys_log.detail(to_s(@vnet))
    call start_debugging()
    $object = to_object(@vnet)
    call sys_log.detail("object:" + to_s($object)+"\n")
    $fields = $object["details"]
    call sys_log.detail("fields:" + to_s($fields) + "\n")
    $vnet = $fields[0]
    call sys_log.detail("vnet:" + to_s($vnet))
    $vnet["tags"] = {}
    $vnet["tags"] = $tags
    $vnet["properties"]["DhcpOptions"] = {}
    $vnet["properties"]["DhcpOptions"]["dnsServers"] = []
    $vnet["properties"]["DhcpOptions"]["dnsServers"][0] = $dns1
    $vnet["properties"]["DhcpOptions"]["dnsServers"][1] = $dns2
    call sys_log.detail("updated_vnet:" + to_s($vnet))
    call start_debugging()
    @updated_vnet = @vnet.update($vnet)
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