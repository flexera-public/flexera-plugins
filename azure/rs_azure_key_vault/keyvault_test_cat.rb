name 'Azure Key Vault - Test CAT'
rs_ca_ver 20161221
short_description "Azure Key Vault - Test CAT"
import "sys_log"
import "plugins/rs_azure_keyvault"

parameter "subscription_id" do
  like $rs_azure_containerservices.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
end

resource "my_vault", type: "rs_azure_keyvault.vaults" do
  name join(["myvault-",last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  location "Central US"
  properties do {
    "accessPolicies" => [],
    "createMode" => "default",
    "enableSoftDelete" => "true",
    "enabledForDeployment" => "true",
    "enabledForDiskEncryption" => "false",
    "enabledForTemplateDeployment" => "false",
    "sku" => {
      "family" => "A",
      "name" => "standard"
    },
    "tenantId" => "09b8fec1-4b8d-48dd-8afa-5c1a775ea0f2"
  } end 
end 