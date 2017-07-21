name 'Azure LB Test CAT'
rs_ca_ver 20161221
short_description "Azure Load Balancing - Test CAT"
import "sys_log"
import "plugins/rs_azure_lb"

parameter "subscription_id" do
  like $rs_azure_lb.subscription_id
end

parameter "resource_group" do
  type  "string"
  label "Resource Group"
end

output "publiclb_id" do
  label "PublicLB-ID"
  category "LoadBalancer"
  default_value @my_pub_lb.id
end

output "privatelb_id" do
  label "PrivateLB-ID"
  category "LoadBalancer"
  default_value @my_priv_lb.id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_pub_lb", type: "rs_azure_lb.load_balancer" do
  name join(["my-pub-lb-", last(split(@@deployment.href, "/"))])
  resource_group "rs-default-centralus"
  location "Central US"
  frontendIPConfigurations do [
    {
     "name" => "ip1",
     "properties" => {
        "publicIPAddress" => {
           "id" => "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/DF-Testing/providers/Microsoft.Network/publicIPAddresses/Shade"
        }
      }
    }
  ] end

  backendAddressPools do [
    {
      "name" => "pool1" 
    }
  ] end

  loadBalancingRules do [
    {
      "name"=> "HTTP Traffic",
      "properties" => {
         "frontendIPConfiguration" => {
            "id" => join(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/frontendIPConfigurations/ip1"])
         },  
         "backendAddressPool" => {
            "id" => join(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/backendAddressPool/pool1"])
         },  
         "protocol" => "Http",
         "frontendPort" => 80,
         "backendPort" => 8080,
         "probe" => {
            "id" => join(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/probes/probe1"])
         },
         "enableFloatingIP" => true,
         "idleTimeoutInMinutes" => 4,
         "loadDistribution" => "Default"
      }
    }  
  ] end

  probes do [
    {
      "name" =>  "probe1",
      "properties" => {
        "protocol" =>  "Http",
        "port" =>  8080,
        "requestPath" =>  "/",
        "intervalInSeconds" =>  5,
        "numberOfProbes" =>  16
      }
    }
  ] end
end

resource "my_priv_lb", type: "rs_azure_lb.load_balancer" do
  name join(["my-priv-lb-", last(split(@@deployment.href, "/"))])
  resource_group "rs-default-centralus"
  location "Central US"
  frontendIPConfigurations do [
    {
     "name" => "ip1",
     "properties" => {
        "subnet" => {
           "id" => "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/virtualNetworks/ARM-CentralUS/subnets/default"
        },
        "privateIPAllocationMethod" => "Dynamic"
      }
    }
  ] end

  backendAddressPools do [
    {
      "name" => "pool1" 
    }
  ] end

  loadBalancingRules do [
    {
      "name"=> "HTTP Traffic",
      "properties" => {
         "frontendIPConfiguration" => {
            "id" => join(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/",join(["my-priv-lb-", last(split(@@deployment.href, "/"))]),"/frontendIPConfigurations/ip1"])
         },  
         "backendAddressPool" => {
            "id" => join(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/",join(["my-priv-lb-", last(split(@@deployment.href, "/"))]),"/backendAddressPool/pool1"])
         },  
         "protocol" => "Http",
         "frontendPort" => 80,
         "backendPort" => 8080,
         "probe" => {
            "id" => join(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rs-default-centralus/providers/Microsoft.Network/loadBalancers/",join(["my-priv-lb-", last(split(@@deployment.href, "/"))]),"/probes/probe1"])
         },
         "enableFloatingIP" => true,
         "idleTimeoutInMinutes" => 4,
         "loadDistribution" => "Default"
      }
    }  
  ] end

  probes do [
    {
      "name" =>  "probe1",
      "properties" => {
        "protocol" =>  "Http",
        "port" =>  8080,
        "requestPath" =>  "/",
        "intervalInSeconds" =>  5,
        "numberOfProbes" =>  16
      }
    }
  ] end
end