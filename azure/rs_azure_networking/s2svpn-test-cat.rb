name 'Azure S2S VPN - Test CAT'
rs_ca_ver 20161221
short_description "Azure S2S VPN - Test CAT"
import "sys_log"
import "plugins/rs_azure_networking"

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

output "ip1" do
  label "VPN IP"
end

parameter "subscription_id" do
  like $rs_azure_networking.subscription_id
end

parameter "param_vpn_ip_id" do
  label "VPN IP ID"
  type "string"
end

parameter "param_remote_ip" do
  label "Remote VPN IP"
  type "string"
end

parameter "param_remote_subnet" do
  label "Remote VPN Subnet"
  description "Can not be 169.245.X.X"
  type "string"
end

parameter "param_remote_asn" do
  label "Remote VPN ASN"
  type "string"
  default "64512"
end

parameter "param_local_asn" do
  label "Local VPN ASN"
  type "string"
  default "65515"
end

resource "resource_group", type: "rs_cm.resource_group" do
  name @@deployment.name
  cloud "AzureRM Central US"
end

resource "network", type: "rs_cm.network" do
  name join(["my-network-", last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
  cidr_block "192.168.2.0/24"
end

resource "subnet", type: "rs_cm.subnet" do
  name "GatewaySubnet"
  network @network
  cloud "AzureRM Central US"
  cidr_block "192.168.2.0/24"
end

resource "local_gateway", type: "rs_azure_networking.local_network_gateway" do
  name join(["my-local-gw",last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  properties do {
    "localNetworkAddressSpace" => {
      "addressPrefixes" => [$param_remote_subnet]
    },
    "gatewayIpAddress": $param_remote_ip,
    "bgpSettings" => {
      "asn" => $param_remote_asn,
      "bgpPeeringAddress" => $param_remote_ip
    }
  } end
end

resource "virtual_gateway", type: "rs_azure_networking.virtual_network_gateway" do
  name join(["my-virtual-gw",last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  properties do {
    "ipConfigurations" => [
      {
        "properties" => {
          "privateIPAllocationMethod" => "Dynamic",
          "subnet" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Network/virtualNetworks/",join(["my-network-", last(split(@@deployment.href, "/"))]),"/subnets/GatewaySubnet"])
          },
          "publicIPAddress" => {
            "id" => $param_vpn_ip_id
          }
        },
        "name" => join(["vng-ip-configuration-",last(split(@@deployment.href, "/"))])
      }
    ],
    "sku": {
      "name": "VpnGw1",
      "tier": "VpnGw1",
      "capacity": 2
    },
    "gatewayType" => "Vpn",
    "vpnType" => "RouteBased",
    "enableBgp" => true,
    "activeActive" => false,
    "bgpSettings" => {
      "asn" => $param_local_asn
    }
  } end
end

resource "connection", type: "rs_azure_networking.virtual_network_gateway_connections" do
  name join(["my-connection",last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  properties do {
    "virtualNetworkGateway1" => {
      "properties" => {
        "ipConfigurations" => [
          {
            "properties" => {
              "privateIPAllocationMethod": "Dynamic",
              "subnet" => {
                "id": join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Network/virtualNetworks/",join(["my-network-", last(split(@@deployment.href, "/"))]),"/subnets/GatewaySubnet"])
              },
              "publicIPAddress" => {
                "id": $param_vpn_ip_id
              }
            },
            "name": join(["vng-ip-configuration-",last(split(@@deployment.href, "/"))]),
          }
        ],
        "sku": {
          "name": "VpnGw1",
          "tier": "VpnGw1",
          "capacity": 2
        },
        "gatewayType": "Vpn",
        "vpnType": "RouteBased",
        "enableBgp": true,
        "activeActive": true
      },
      "id": @virtual_gateway.id,
      "location": "centralus"
    },
    "localNetworkGateway2" => {
      "properties" => {
        "localNetworkAddressSpace" => {
          "addressPrefixes" => [$param_remote_subnet]
        },
        "gatewayIpAddress": $param_remote_ip,
        "bgpSettings" => {
          "asn" => $param_remote_asn,
          "bgpPeeringAddress" => $param_remote_ip
        }
      },
      "id": @local_gateway.id,
      "location": "centralus"
    },
    "connectionType": "IPsec",
    "connectionProtocol": "IKEv2",
    "routingWeight": 0,
    "sharedKey": "Flexera12345",
    "enableBgp": true,
    "usePolicyBasedTrafficSelectors": false,
    "ipsecPolicies" => []
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

operation "terminate" do 
  definition "terminate"
end

define launch_handler(@resource_group,@network,@subnet,$param_vpn_ip_id,$subscription_id,$param_local_asn,$param_remote_asn,$param_remote_ip,$param_remote_subnet,@local_gateway,@virtual_gateway,@connection) return @resource_group,@network,@subnet,$subscription_id,$param_local_asn,$param_remote_asn,$param_remote_ip,$param_remote_subnet,@local_gateway,@virtual_gateway,@connection do
  provision(@resource_group)
  provision(@network)
  provision(@subnet)
  provision(@local_gateway)
  provision(@virtual_gateway)
  provision(@connection)
end

define terminate(@resource_group,@network,@subnet,@local_gateway,@virtual_gateway,@connection) return @resource_group,@network,@subnet,@local_gateway,@virtual_gateway,@connection do
  delete(@connection)
  delete(@virtual_gateway)
  delete(@local_gateway)
  delete(@subnet)
  delete(@network)
  delete(@resource_group)
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
