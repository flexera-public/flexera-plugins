name 'Azure Application Gateway - Test CAT'
rs_ca_ver 20161221
short_description "Azure Application Gateway - Test CAT"
import "sys_log"
import "plugins/rs_azure_application_gateway"
import "plugins/rs_azure_networking"

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

parameter "subscription_id" do
  like $rs_azure_application_gateway.subscription_id
  default "9ae470b8-66cb-496a-9bc3-bbf4eedd408f"
  #default "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
end

parameter "param_subnet" do
    type "string"
    label "Region : vNet : Subnet"
    #description "json:{\"definition\":\"getSubnets\", \"description\": \"Pick the 'Region : vNet : Subnet' combination where you would like to launch the server.\"}"
    min_length 1
    operations "launch"
    default 'AzureRM East US : Default-vnet : default'
end

parameter "param_tier" do
  like $rs_azure_application_gateway.tier
end

parameter "param_instance_count" do
  like $rs_azure_application_gateway.instance_count
end

parameter "param_sku" do
  like $rs_azure_application_gateway.sku
end

parameter "param_public_ip" do
  like $rs_azure_application_gateway.public_ip
end

parameter "param_ssl_cred" do
  like $rs_azure_application_gateway.ssl_cred
  default "APPGATEWAY_PLUGIN"
end

mapping "mapping_sku_name" do {
  "Standard" => {
    "Small"   =>  "Standard_Small",
    "Medium"  =>  "Standard_Medium",
    "Large"   =>  "Standard_Large",
  },
  "WAF" => {
    "Small"   =>  "WAF_Medium",
    "Medium"  =>  "WAF_Medium",
    "Large"   =>  "WAF_Large",
  }
}
end

resource "rg", type: "rs_cm.resource_group" do
  name join(["appgw-rg-",last(split(@@deployment.href, "/"))])
  cloud find(first(split($param_subnet, ' : ')))
end

resource "ip", type: "rs_azure_networking.public_ip_address" do
  name join(["appgw-", last(split(@@deployment.href, "/")),"-publicip"])
  resource_group @rg.name
  location 'eastus'
  properties do {
    "publicIPAllocationMethod" => "Dynamic",
    "publicIPAddressVersion" => "IPv4"
  } end
  sku do {
    "name" => "Basic"
  } end
end

resource "appgw", type: "rs_azure_application_gateway.gateway" do
  name join(["appgw-",last(split(@@deployment.href, "/"))])
  resource_group @rg.name
  location 'eastus'
  properties do {
    sku:  {
      capacity: $param_instance_count,
      name: map($mapping_sku_name,$param_tier,$param_sku),
      tier: $param_tier,
    },
    gatewayIPConfigurations: [
      {
        name: join(["appgw-",last(split(@@deployment.href, "/")),'-gwipconfig']),
        properties:{
          subnet: {
            id: 'stubbed,set in launch'
          }
      }
    }
    ],
    frontendIPConfigurations:[{
      name: join(["appgw-",last(split(@@deployment.href, "/")),"-frontipconfig"]),
      properties:{
        publicIPAddress: {
          id: 'stubbed, set in launch'
        }
      }
    }],
    frontendPorts:[{
      name: join(["appgw-",last(split(@@deployment.href, "/")),"-fp443"]),
      "properties" => {
        "port" => 80
      },
    }],
    backendAddressPools: [
      {
        name: join(["appgw-",last(split(@@deployment.href, "/")),"-backendpool"]),
        properties: {
          # backendAddresses: [
          #   {
          #     "ipAddress": "10.0.1.1"
          #   },
          #   {
          #     "ipAddress": "10.0.1.2"
          #   }
          # ]
        }
      }
    ],
    backendHttpSettingsCollection: [
      {
        name: join(["appgw-",last(split(@@deployment.href, "/")),"-bhs"]),
        properties: {
          port: 80,
          protocol: "Http",
          cookieBasedAffinity: "Disabled",
          requestTimeout: 30
        }
      }
    ],
     httpListeners: [
       {
        name: join(["appgw-",last(split(@@deployment.href, "/")),"-httplistener"]),
        properties: {
          frontendIPConfiguration: {
            id: join(["/subscriptions/",$subscription_id,"/resourceGroups/",@rg.name,"/providers/Microsoft.Network/applicationGateways/",join(["appgw-",last(split(@@deployment.href, "/"))]),"/frontendIPConfigurations/",join(["appgw-",last(split(@@deployment.href, "/")),"-frontipconfig"])])
          },
          frontendPort: {
            id: join(["/subscriptions/",$subscription_id,"/resourceGroups/",@rg.name,"/providers/Microsoft.Network/applicationGateways/",join(["appgw-",last(split(@@deployment.href, "/"))]),"/frontendPorts/",join(["appgw-",last(split(@@deployment.href, "/")),"-fp443"])])
          },
          protocol: "Http"
        }
      }
    ],
     requestRoutingRules: [
           {
             name: join(["appgw-",last(split(@@deployment.href, "/")),"-rule1"]),
             properties: {
               ruleType: "Basic",
               httpListener: {
                 id: join(["/subscriptions/",$subscription_id,"/resourceGroups/",@rg.name,"/providers/Microsoft.Network/applicationGateways/",join(["appgw-",last(split(@@deployment.href, "/"))]),"/httpListeners/",join(["appgw-",last(split(@@deployment.href, "/")),"-httplistener"])])
               },
               backendAddressPool: {
                 id: join(["/subscriptions/",$subscription_id,"/resourceGroups/",@rg.name,"/providers/Microsoft.Network/applicationGateways/",join(["appgw-",last(split(@@deployment.href, "/"))]),"/backendAddressPools/",join(["appgw-",last(split(@@deployment.href, "/")),"-backendpool"])])
               },
               backendHttpSettings: {
                 id: join(["/subscriptions/",$subscription_id,"/resourceGroups/",@rg.name,"/providers/Microsoft.Network/applicationGateways/",join(["appgw-",last(split(@@deployment.href, "/"))]),"/backendHttpSettingsCollection/",join(["appgw-",last(split(@@deployment.href, "/")),"-bhs"])])
               },
             }
           },
         ],

    # sslCertificates:[{
    #   properties:{
    #     data: 'stubbed set in launch'
    #   }
    # }]
  } end
  tags do {
      "defaultExperience" => "DocumentDB",
      "costcenter" => "12345",
      "envrionment" => "dev",
      "department" => "engineering"
  } end
  # zones do {
  #
  #
  #  } end
end

output "output_name" do
  label "Azure Application Gateway Name"
end

output "output_uri" do
  label "Azure Application Gateway URI"
end

output "output_state" do
  label "Azure Application Gateway State"
end

output "output_address" do
  label "Azure Application Gateway Address"
end

operation "launch" do
  description "Launch the application"
  definition "launch_handler"
  output_mappings do {
    $output_uri => $uri,
    $output_name => @appgw.name,
    $output_state => @appgw.state,
    $output_address => $address
  } end
 end

 define launch_handler(@rg,@appgw,@ip,$param_subnet,$param_tier,$param_sku,$param_subnet,$param_instance_count,$param_public_ip,$param_ssl_cred) return $uri,$state,@appgw,@rg,@ip,$address do
   call start_debugging()
   provision(@rg)
   @cloud = find('clouds',first(split($param_subnet, ' : ')))
   @subnet = find('subnets',last(split($param_subnet, ' : ')))
   @cred = find('credentials',$param_ssl_cred)

   if $param_public_ip == ''
     provision(@ip)
   else
     raise "getting ip address not supported yet"
   end

   sleep_until(@ip.properties['provisioningState'] == 'Succeeded')

   # modify the gateway base on inputs
   $gateway = to_object(@appgw)

   # overwrite the location attribute
   #$gateway['fields']['location'] = @cloud.display_name
   # add the subnet
   $gateway['fields']['properties']['gatewayIPConfigurations'][0]['properties']['subnet']['id'] = @subnet.resource_uid
   #add the public_ip
   $gateway['fields']['properties']['frontendIPConfigurations'][0]['properties']['publicIPAddress']['id'] = @ip.id
   #$gateway['fields']['properties']['frontendIPConfigurations'][0]['properties']['subnet'][id] = @subnet.resource_uid
   #add the SSL Certificate from the Credential from the Public IP Addreess Input
   #$gateway['fields']['properties']['sslCertificates'][0]['properties']['data'] = @cred.value

   @appgw = $gateway
   provision(@appgw)
   call stop_debugging()
   $uri = join(["https://" + @appgw.name, ".", 'eastus',".cloudapp.azure.com"])
   $address = @ip.properties["ipAddress"]
 end

 define getSubnets() return $values do
   $values = []
   $networksArray = []

   # Get all AzureRM clouds
   $clouds = rs_cm.clouds.get( filter: ["cloud_type==azure_v2"] )
   $clouds = $clouds[0]

   foreach $cloud in $clouds do
     $cloudName = $cloud["name"]
     $cloudHref = $cloud["links"][0]["href"]

     $networks = rs_cm.networks.get(filter: [join(["cloud_href==",$cloudHref])])
     $networks = $networks[0]
     foreach $network in $networks do
       $networksArray << {
         "name": $network["name"],
         "href": $network["links"][0]["href"]
       }
     end

     $subnets = rs_cm.clouds.get(href: $cloudHref).subnets()
     $subnets = $subnets[0]
     foreach $subnet in $subnets do
       $networkHash = first(select($networksArray, {"href": $subnet["links"][1]["href"]}))
       $values << $cloudName + " : " + $networkHash["name"] + " : " + $subnet["name"]
     end
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
