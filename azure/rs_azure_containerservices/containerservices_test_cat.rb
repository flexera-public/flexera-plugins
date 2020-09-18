name 'Azure Container Service Test CAT'
rs_ca_ver 20161221
short_description "Azure Container Service  - Test CAT"
import "sys_log"
import "plugins/rs_azure_containerservices"

parameter "subscription_id" do
  like $rs_azure_containerservices.subscription_id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_resource_group", type: "rs_cm.resource_group" do
  cloud_href "/api/clouds/3526"
  name @@deployment.name
  description join(["container resource group for ", @@deployment.name])
end

# https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-dcos
# https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-dcos/azuredeploy.parameters.json
resource "my_container", type: "rs_azure_containerservices.containerservice" do
  name join(["myc", last(split(@@deployment.href, "/"))])
  resource_group @my_resource_group.name
  location "Central US"
  properties do {
   "orchestratorProfile" => {
      "orchestratorType" =>  "DCOS"
    },
    "masterProfile" => {
      "count" =>  "1",
      "dnsPrefix" =>  join([@@deployment.name, "-master"])
    },
    "agentPoolProfiles" =>  [
      {
        "name" =>  "agentpools",
        "count" =>  "2",
        "vmSize" =>  "Standard_DS2",
        "dnsPrefix" =>  join([@@deployment.name, "-agent"])
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
            "keyData" =>  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1CfyxgqRTbPSXpLqEa9VbvtJxEcxI1JsB/9Dw0hha4PCIGw5pX7X/Dl8UbnkbvzUuzvDQ3Ap6jZpYB4sHRTN/8fv1F9HnQ5xkDRfyH2fnZmhrihlxzwy1AvufNhGqwPEZLl8znxRG94UR2oqa1KBtVX+zvjoAdrhAsuhNcix/3VpTkeoCyEjNknl3Jy8VYCX4CH0cQpyl/gjWGmXF4YxyyLeZ4LzRfUQl2lXH/eF4h0MwZsYSJChiR1UU6FSD4+NJbJa01gLCMJmox8DwKABK/iPnulR/gsTG/HLEXTtkqIrOaIuBnNsfnq2dkOcGgXDFbTi9X0irWZow/lQcJ0M5 container"
          }
        ]
      }
    }
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler(@my_resource_group,@my_container) return @my_resource_group,@my_container do
  call start_debugging()
  provision(@my_resource_group)
  provision(@my_container)
  call stop_debugging()
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