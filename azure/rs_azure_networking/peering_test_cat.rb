name 'Azure Peering Test'
rs_ca_ver 20161221
short_description 'Azure Peering - Test CAT'

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
  name        join(["network1-", last(split(@@deployment.href, "/"))])
  description	join(["network1-", last(split(@@deployment.href, "/"))])
  cloud       'AzureRM Central US'
  cidr_block  '10.1.0.0/16'
end

resource 'network2', type: 'network' do
  name        join(["network2-", last(split(@@deployment.href, "/"))])
  description	join(["network2-", last(split(@@deployment.href, "/"))])
  cloud       'AzureRM Central US'
  cidr_block  '10.2.0.0/16'
end

resource 'net1_to_net2', type: 'rs_azure_networking.peering' do
  name 'net1-to-net2'
  resource_group "@@deployment.resource_group().name"
  subscription_id $subscription_id
  local_vnet @network1.name
  remote_vnet @network2.name
  properties do {
      'allowVirtualNetworkAccess' => true,
      'allowForwardedTraffic' => false,
      'allowGatewayTransit' => false,
      'useRemoteGateways' => false
  } end
end

resource 'net2_to_net1', type: 'rs_azure_networking.peering' do
  name 'net2-to-net1'
  resource_group "@@deployment.resource_group().name"
  subscription_id $subscription_id
  local_vnet @network2.name
  remote_vnet @network1.name
  properties do {
      'allowVirtualNetworkAccess' => true,
      'allowForwardedTraffic' => false,
      'allowGatewayTransit' => false,
      'useRemoteGateways' => false
  } end
end
