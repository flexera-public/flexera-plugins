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
  default "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
end

parameter "param_subnet" do
    type "string"
    label "Region : vNet : Subnet"
    description "json:{\"definition\":\"getSubnets\", \"description\": \"Pick the 'Region : vNet : Subnet' combination where you would like to launch the server.\"}"
    min_length 1
    operations "launch"
    #default 'AzureRM East US : Default-vnet : default'
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

parameter "param_ssl_cred" do
  like $rs_azure_application_gateway.ssl_cred

end

parameter "param_ssl_cred_password" do
  like $rs_azure_application_gateway.ssl_cred_password

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

mapping "mapping_regions" do {
  "AzureRM West US" => {
    "name"=> 'westus',
    "zones"=> [],
  },
  "AzureRM Japan East" =>{
    "name"=> 'japaneast',
    "zones"=> [],
  },
  "AzureRM Southeast Asia" => {
    "name"=> 'southeastasia',
    "zones"=> [],
  },
  "AzureRM Japan West" =>{
    "name"=> 'japanwest',
    "zones"=> []
  },
  "AzureRM East Asia" =>{
    "name"=> 'eastasia',
    "zones"=> []
  },
  "AzureRM East US" => {
    "name"=> 'eastus',
    "zones"=> []
  },
  "AzureRM West Europe"=>{
    "name"=> 'westeurope',
    "zones"=> []
  },
  "AzureRM North Central US"=>{
    "name"=> 'northcentralus',
    "zones"=> []
  },
  "AzureRM Central US"=>{
    "name"=> 'centralus',
    "zones"=> []
  },
  "AzureRM Canada Central"=>{
    "name"=> 'CanadaCentral',
    "zones"=> []
  },
  "AzureRM North Europe"=>{
    "name"=> 'northeurope',
    "zones"=> []
  },
  "AzureRM Brazil South"=>{
    "name"=> 'brazilsouth',
    "zones"=> []
  },
  "AzureRM Canada East"=>{
    "name"=> 'CanadaEast',
    "zones"=> []
  },
  "AzureRM East US 2"=>{
    "name"=> 'eastus2',
    "zones"=> []
  },
  "AzureRM South Central US"=>{
    "name"=> 'southcentralus',
    "zones"=> []
  },
  "AzureRM Australia East"=>{
    "name"=> 'australiaeast',
    "zones"=> []
  },
  "AzureRM Australia Southeast"=>{
    "name"=> 'australiasoutheast',
    "zones"=> []
  },
  "AzureRM West US 2"=>{
    "name"=> 'westus2',
    "zones"=> []
  },
  "AzureRM West Central US"=>{
    "name"=> 'westcentralus',
    "zones"=> []
  },
  "AzureRM UK South"=>{
    "name"=> 'uksouth',
    "zones"=> []
  },
  "AzureRM UK West"=>{
    "name"=> 'ukwest',
    "zones"=> []
  },
  "AzureRM West India"=>{
    "name"=> 'WestIndia',
    "zones"=> []
  },
  "AzureRM Central India"=>{
    "name"=> 'CentralIndia',
    "zones"=> []
  },
  "AzureRM South India"=>{
    "name"=> 'SouthIndia',
    "zones"=> []
  },
  "AzureRM Korea Central"=>{
    "name"=> 'KoreaCentral',
    "zones"=> []
  },
  "AzureRM Korea South"=>{
    "name"=> 'KoreaSouth',
    "zones"=> []
  },

} end

resource "rg", type: "rs_cm.resource_group" do
  name join(["appgw-rg-",last(split(@@deployment.href, "/"))])
  cloud find(first(split($param_subnet, ' : ')))
end

resource "ip", type: "rs_azure_networking.public_ip_address" do
  name join(["appgw-", last(split(@@deployment.href, "/")),"-publicip"])
  resource_group @rg.name
  location map($mapping_regions,first(split($param_subnet, ' : ')),"name")
  properties do {
    "publicIPAllocationMethod" => "Dynamic",
    "publicIPAddressVersion" => "IPv4",
    dnsSettings:{
      domainNameLabel: join(["appgw-",last(split(@@deployment.href, "/"))]),
    }
  } end
  sku do {
    "name" => "Basic"
  } end
end

resource "appgw", type: "rs_azure_application_gateway.gateway" do
  name join(["appgw-",last(split(@@deployment.href, "/"))])
  resource_group @rg.name
  location map($mapping_regions,first(split($param_subnet, ' : ')),"name")
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
        "port" => 443
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
          protocol: "Https",
          sslCertificate: {
            id: join(["/subscriptions/",$subscription_id,"/resourceGroups/",@rg.name,"/providers/Microsoft.Network/applicationGateways/",join(["appgw-",last(split(@@deployment.href, "/"))]),"/sslCertificates/",join(["appgw-",last(split(@@deployment.href, "/")),"-sslCert"])])
          }
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
      sslCertificates:[
        {
              name: join(["appgw-",last(split(@@deployment.href, "/")),"-sslCert"]),
              # "properties": {
              #   "keyVaultSecretId": "https://kv/sslCert"
              # }
              properties:{
                data: cred($param_ssl_cred),
                password: cred($param_ssl_cred_password)
            }
        }
      ],
      webApplicationFirewallConfiguration:{

      }
  } end
  tags do {
      "defaultExperience" => "DocumentDB",
      "costcenter" => "12345",
      "envrionment" => "dev",
      "department" => "engineering"
  } end
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

 operation "terminate" do
   description "Launch the resources"
   definition "terminate"
 end

 define launch_handler(@rg,@appgw,@ip,$param_subnet,$param_tier,$param_sku,$param_subnet,$param_instance_count,$param_ssl_cred) return $uri,$state,@appgw,@rg,@ip,$address do
   call start_debugging()

   provision(@rg)
   @cloud = find('clouds',first(split($param_subnet, ' : ')))
   @network = find('networks', get(1, split($param_subnet, ' : ')))
   @subnet = find('subnets',{name: last(split($param_subnet, ' : ')), network_href: @network.href} )

   provision(@ip)
   sleep_until(@ip.properties['provisioningState'] == 'Succeeded')

   # modify the gateway base on inputs
   $gateway = to_object(@appgw)

   # add the subnet
   $gateway['fields']['properties']['gatewayIPConfigurations'][0]['properties']['subnet']['id'] = @subnet.resource_uid
   # add the public_ip,
   $gateway['fields']['properties']['frontendIPConfigurations'][0]['properties']['publicIPAddress']['id'] = @ip.id

   # if use select tier "WAF", setup the WAF properties
   if $param_tier == "WAF"
     $gateway['fields']['properties']['webApplicationFirewallConfiguration']['enabled'] = true
     $gateway['fields']['properties']['webApplicationFirewallConfiguration']['firewallMode'] = 'Detection'
     $gateway['fields']['properties']['webApplicationFirewallConfiguration']['requestBodyCheck'] = false
   end

   @appgw = $gateway
   provision(@appgw)

   call stop_debugging()
   $uri = join(["https://",@ip.properties['dnsSettings']['fqdn']])
   $address = @ip.properties["ipAddress"]
 end

 define terminate(@appgw) do
   delete(@appgw)
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
