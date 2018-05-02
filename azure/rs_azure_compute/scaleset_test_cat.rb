name 'Azure ScaleSet Test CAT'
rs_ca_ver 20161221
short_description "Azure Compute - Test CAT"
import "sys_log"
import "plugins/rs_azure_compute"

parameter "subscription_id" do
  like $rs_azure_compute.subscription_id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "rg", type: "rs_cm.resource_group" do
  name @@deployment.name
  cloud "AzureRM Central US"
end

resource "scaleset", type: "rs_azure_compute.scale_set" do
  name join(["easy-", last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  sku do {
    "tier" => "Standard",
    "capacity" => 3,
    "name" => "Standard_D1_v2"
  } end
  properties do {
    "overprovision" =>  true,
    "virtualMachineProfile" =>  {
      "storageProfile" =>  {
        "imageReference" =>  {
          "sku" =>  "2016-Datacenter",
          "publisher" =>  "MicrosoftWindowsServer",
          "version" =>  "latest",
          "offer" =>  "WindowsServer"
        },
        "osDisk" =>  {
          "caching" =>  "ReadWrite",
          "managedDisk" =>  {
            "storageAccountType" =>  "Standard_LRS"
          },
          "createOption" =>  "FromImage"
        }
      },
      "osProfile" =>  {
        "computerNamePrefix" =>  "vmss-easy",
        "adminUsername" =>  "rightscale",
        "adminPassword" =>  "Password1234@"
      },
      "networkProfile" =>  {
        "networkInterfaceConfigurations" =>  [
          {
            "name" =>  "vmss-easy",
            "properties" =>  {
              "primary" =>  true,
              "enableIPForwarding" =>  true,
              "ipConfigurations" =>  [
                {
                  "name" =>  "vmss-easy",
                  "properties" =>  {
                    "subnet" =>  {
                      "id" =>  join(["/subscriptions/",$subscription_id,"/resourceGroups/rs-default-centralus/providers/Microsoft.Network/virtualNetworks/ARM-CentralUS/subnets/default"])
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    },
    "upgradePolicy" =>  {
      "mode" =>  "Manual"
    }
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler(@rg,@scaleset) return @scaleset,@rg do
  call start_debugging()
  provision(@rg)
  provision(@scaleset)
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