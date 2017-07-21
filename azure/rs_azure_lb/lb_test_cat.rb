name 'SQL Test CAT'
rs_ca_ver 20161221
short_description "Azure SQL Database Service - Test CAT"
import "sys_log"
import "plugins/rs_azure_sql"

parameter "subscription_id" do
  like $rs_azure_sql.subscription_id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "rs_azure_lb", type =>   "rs_azure_lb.load_balancer" do
  name join(["my-load-balance-", last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  location "Central US"
  frontendIPConfigurations do {
   "name" => "my ip 1",  
   "properties" => {
      "subnet" => {
         "id" => "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/DF-Testing/providers/Microsoft.Network/virtualNetworks/myvnet1/subnets/mysubnet1"
      },
      "privateIPAddress" => "10.0.0.10",
      "privateIPAllocationMethod" => "Static",
      "publicIPAddress" => {
         "id" => "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/DF-Testing/providers/Microsoft.Network/publicIPAddresses/myip1"
      }
  } end

  backendAddressPools do [
    {
      "name" => "backend ip pool 1" 
    }
  ] end

  loadBalancingRules do [
    {
      "name"=> "HTTP Traffic",
      "properties" => {
         "frontendIPConfiguration" => {
            "id" => "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/DF-Testing/providers/Microsoft.Network/loadBalancers/myLB1/frontendIPConfigurations/ip1"
         },  
         "backendAddressPool" => {
            "id" => "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/DF-Testing/providers/Microsoft.Network/loadBalancers/myLB1/backendAddressPool/pool1"
         },  
         "protocol" => "Tcp",
         "frontendPort" => 80,
         "backendPort" => 8080,
         "probe" => {
            "id" => "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/DF-Testing/providers/Microsoft.Network/loadBalancers/myLB1/probes/probe1"
         },
         "enableFloatingIP" => true,
         "idleTimeoutInMinutes" => 4,
         "loadDistribution" => "Default"
      }
    }  
  ] end

  probes do [
    {
      "name" =>  "my probe 1",
      "properties" => {
        "protocol" =>  "Tcp",
        "port" =>  8080,
        "requestPath" =>  "myprobeapp1/myprobe1.svc",
        "intervalInSeconds" =>  5,
        "numberOfProbes" =>  16
      }
    }
  ] end

  inboundNatPools do [
  {   
    "name" =>  "RDP Traffic",
    "properties" =>  {
      "frontendIPConfiguration" =>  {
      "id" =>  "/subscriptions/8beb7791-9302-4ae4-97b4-afd482aadc59/resourceGroups/DF-Testing/providersMicrosoft.Network/loadBalancers/myLB1/frontendIPConfigurations/ip1"
    },
    "protocol" =>  "Tcp",
    "frontendPort" =>  3389,
    "backendPort" =>  3389
    }
  }
  ] end
end
