name 'Azure Key Vault - Test CAT'
rs_ca_ver 20161221
short_description "Azure Key Vault - Test CAT"
import "sys_log"
import "plugins/rs_azure_keyvault"

parameter "subscription_id" do
  like $rs_azure_keyvault.subscription_id
  default "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
end

resource "my_vault", type: "rs_azure_keyvault.vaults" do
  name join(["myvault-",last(split(@@deployment.href, "/"))])
  resource_group "Testing"
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
    "tenantId" => "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  } end 
end 