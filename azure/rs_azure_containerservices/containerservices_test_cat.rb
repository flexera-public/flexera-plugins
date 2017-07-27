name 'Azure Container Service Test CAT'
rs_ca_ver 20161221
short_description "Azure Container Service  - Test CAT"
import "sys_log"
import "plugins/rs_azure_containerservices"

parameter "subscription_id" do
  like $rs_azure_containerservices.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

# https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-dcos
# https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-dcos/azuredeploy.parameters.json
resource "my_container", type: "rs_azure_containerservices.containerservice" do
  name join(["mysa", last(split(@@deployment.href, "/"))])
  resource_group "rs-default-centralus"
  location "Central US"
  properties do {
   "orchestratorProfile" => {
      "orchestratorType" =>  "DCOS"
    },
    "masterProfile" => {
      "count" =>  "3",
      "dnsPrefix" =>  "[variables('mastersEndpointDNSNamePrefix')]"
    },
    "agentPoolProfiles" =>  [
      {
        "name" =>  "agentpools",
        "count" =>  "1",
        "vmSize" =>  "Standard_A2",
        "dnsPrefix" =>  "GEN-UNIQUE"
      }
    ],
    "diagnosticsProfile" => {
      "vmDiagnostics" => {
          "enabled" =>  "false"
      }
    },
    "linuxProfile" => {
      "adminUsername" =>  "azureuser",
      "ssh" => {
        "publicKeys" =>  [
          {
            "keyData" =>  "GEN-SSH-PUB-KEY"
          }
        ]
      }
    }
  } end
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