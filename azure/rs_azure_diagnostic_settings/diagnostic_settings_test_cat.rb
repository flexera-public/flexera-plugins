name 'Azure Diagnostic Settings - Test Cat'
rs_ca_ver 20161221
short_description "Azure Diagnostic Settings - Test Cat"
import "sys_log"
import "plugins/rs_azure_keyvault"
import "plugins/rs_azure_diagnostic_settings"

## Permissions
permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

## Mappings

## Parameters
parameter "subscription_id" do
  like $rs_azure_keyvault.subscription_id
end

parameter "tenant_id" do
  label "Tenant ID"
  type "string"
end

parameter "param_cloud" do
  label "Region"
  type "string"
  allowed_values "East US", "Central US", "West US"
  default "East US"
end

## Resources
resource "storage_account", type: "placement_group" do
  name join(["sa",last(split(@@deployment.href, "/"))])
  cloud join(["AzureRM ",$param_cloud])
end

resource "vault", type: "rs_azure_keyvault.vaults" do
  name join(["keyvault-",last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location $param_cloud
  properties do {
    "accessPolicies" => [],
    "createMode" => "default",
    "enableSoftDelete" => "true",
    "enabledForDeployment" => "true",
    "enabledForDiskEncryption" => "true",
    "enabledForTemplateDeployment" => "true",
    "sku" => {
      "family" => "A",
      "name" => "Standard"
    },
    "tenantId" => $tenant_id
  } end
end

resource "vault_diagnostic_settings", type: "rs_azure_diagnostic_settings.diagnostic_settings" do
  name join(["diagnostic_settings-",last(split(@@deployment.href, "/"))])
  resource_uri @vault.id
  location ""
  properties do {
    "storageAccountId" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Storage/storageAccounts/",@storage_account.name]),
    "logs" => [
      {
      "category" => "AuditEvent",
      "enabled" => "true",
      "retentionPolicy" => {
        "enabled" => "false",
        "days" => 0
        }
      }
    ]
  } end
end

## Outputs
output "output_vault_name" do
  label "Key Vault Name"
  category "Azure Key Vault"
  description "The name of the key vault"
  default_value @vault.name
end

output "output_vault_resource_id" do
  label "Key Vault Resource ID"
  category "Azure Key Vault"
  description "The Azure Resource Manager resource ID for the key vault"
  default_value @vault.id
end

output "output_vault_uri" do
  label "Key Vault URI"
  category "Azure Key Vault"
  description "The URI of the vault for performing operations on keys and secrets"
  default_value @vault.vault_uri
end
