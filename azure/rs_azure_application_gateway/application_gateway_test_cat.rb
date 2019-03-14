name 'Azure Application Gateway - Test CAT'
rs_ca_ver 20161221
short_description "Azure Application Gateway - Test CAT"
import "sys_log"
import "plugins/rs_azure_application_gateway"

parameter "subscription_id" do
  like $rs_azure_application_gateway.subscription_id
  default "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
end

parameter "param_subnet" do
    label "Region : vNet : Subnet"
    type "string"
    description "json:{\"definition\":\"getSubnets\", \"description\": \"Pick the 'Region : vNet : Subnet' combination where you would like to launch the server.\"}"
    min_length 1
    operations "launch"
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

mapping "sku_name" do {
  "Standard" => {
    "Small"   =>  "Small_Standard",
    "Medium"  =>  "Small_Medium",
    "Large"   =>  "Small_Large",
  },
  "WAF" => {
    "Small"   =>  "WAF_Standard",
    "Medium"  =>  "WAF_Medium",
    "Large"   =>  "WAF_Large",
  }
}
end

resource "rg", type: "rs_cm.resource_group" do
  name join(["appgw-rg-",last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
end

resource "gateway", type: "rs_azure_application_gateway.gateway" do
  name join(["appgw-",last(split(@@deployment.href, "/"))])
  resource_group @rg.name
  location find(first(split($param_subnet, ' : '))).name
  properties do {
    sku: {
      capacity: $param_instance_count,
      name: map($mapping_sku_name,$param_tier,$param_sku),
      tier: $param_tier,
    },
    gatewayIPConfigurations: [
      {
        name: join(["appgw-",last(split(@@deployment.href, "/")),'-gwipconfig']),
        properties: {
          subnet: {
            id: find(last(split($param_subnet, ' : '))).resource_uid
            #id: join(["/subscriptions/",$subscription_id,"/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/vnet/subnets/",find(last(split($param_subnet, ' : ')))])
          }
        }
      }
    ],
    frontendIPConfigurations:[{
      name: join(["appgw-",last(split(@@deployment.href, "/")),"-frontipconfig"]),
      properties:{
        privateIPAllocationMethod: 'Dynamic',
      }
    }],
    frontendPorts:[{
      name: join(["appgw-",last(split(@@deployment.href, "/")),"-fp80"]),
      properties: {
        port: 80
      },
    }],
    sslCertificates:{

    }
  } end
  tags do {
      "defaultExperience" => "DocumentDB",
      "costcenter" => "12345",
      "envrionment" => "dev",
      "department" => "engineering"
  } end
  zones do {


   } end
end

output "output_uri" do
  label "Azure Application Gateway URI"
end

output "output_state" do
  label "Azure Application Gateway State"
end

operation "launch" do
  description "Launch the application"
  definition "launch_handler"
  output_mappings do {
    $output_uri => $uri,
    $output_state => $state,
  } end
 end

 define launch_handler(@rg,@gateway,$param_subnet,$param_tier,$param_sku,$param_subnet,$param_instance_count) return $uri,$state,@gateway,@rg do
   call start_debugging()
   provision(@rg)
   provision(@gateway)
   call stop_debugging()
   $uri = "https://" + @gateway.name
   $state = to_s(@gateway.state)
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
