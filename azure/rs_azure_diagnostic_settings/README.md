# Azure Service Diagnostic Settings Plugin

## Overview
The Azure Service Diagnostic Settings Plugin integrates RightScale Self-Service with the functionality of the Service Diagnostic Settings resource in the Azure API. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- Azure Service Principal (AKA Azure Active Directory Application) with the appropriate permissions to manage resources in the target subscription
- The following RightScale Credentials
  - `AZURE_APPLICATION_ID`
  - `AZURE_APPLICATION_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)


## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AzureRM Cloud credentials to your RightScale account (if not already completed)
1. Follow steps to [Create an Azure Active Directory Application](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#create-an-azure-active-directory-application)
1. Grant the Azure AD Application access to the necessary subscription(s)
1. [Retrieve the Application ID & Authentication Key](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
1. Create RightScale Credentials with values that match the Application ID (Credential name: `AZURE_APPLICATION_ID`) & Authentication Key (Credential name: `AZURE_APPLICATION_KEY`)
1. [Retrieve your Tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)
1. Update `rs_azure_diagnostic_settings_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `rs_azure_diagnostic_settings_plugin.rb` file located in this repository
 
## How to Use
The plugin has been packaged as `plugins/rs_azure_diagnostic_settings`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_diagnostic_settings"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Plugin Parameters
### subscription_id
There is a "subscription_id" Plugin Parameter in the Plugin.  Recommended usage (where the `default` value matches your target Subscription ID):
```
parameter "subscription_id" do
  like $rs_azure_template.subscription_id
  default "12345678-1234-1234-1234-123456789012"
end
```
**Note:** `default` is not a required field.  You could, instead, elect to populate this parameter at every CloudApp Launch.

## Supported Resources
### diagnostic_settings

#### Supported Fields
**Note:** There are many possible configurations when defining a `diagnostic_settings` resource.  More detailed API documentation is available [here](https://docs.microsoft.com/en-us/rest/api/monitor/servicediagnosticsettings).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | Reference name | 
| resource_uri | yes | Uri of the resource to configure diagnostic settings on| 
| location | yes | even though its required, the value should be empty |
| properties | yes | Hash of diagnostic settings (see examples and Azure API documentation for more details) | 

#### Supported Outputs
- id
- name

#### Usage
Service Diagnostic Settings can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Configures AuditEvent logging on a KeyVault
resource "vault_diagnostic_settings", type: "rs_azure_diagnostic_settings.diagnostic_settings" do
  name join(["diagnostic_settings-",last(split(@@deployment.href, "/"))])
  resource_uri "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RightScale-Testing/providers/Microsoft.KeyVault/vaults/RS-Vault"
  location ""
  properties do {
    "storageAccountId" => "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RightScale-Testing/providers/Microsoft.Storage/storageAccounts/rskeyvaultaudits",
    "logs" => [ {
      "category" => "AuditEvent",
      "enabled" => "true",
      "retentionPolicy" => {
        "enabled" => "false",
        "days" => 0
      }
    } ]
  } end
end
```

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create & update | [Service Diagnostic Settings - CreateOrUpdate](https://docs.microsoft.com/en-us/rest/api/monitor/servicediagnosticsettings/createorupdate) | Supported |
| get | [Service Diagnostic Settings - Get](https://docs.microsoft.com/en-us/rest/api/monitor/servicediagnosticsettings/get) | Supported |
| update | [Service Diagnostic Settings - Update](https://docs.microsoft.com/en-us/rest/api/monitor/servicediagnosticsettings/update) | Supported |

## Examples
Please review [diagnostic_settings_test_cat.rb](./Adiagnostic_settings_test_cat.rb) for a basic example implementation that creates a Storage Account, Key Vault and configures Diagnostic Settings for Audit Logging.
	
## Known Issues / Limitations
- None

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Service Diagnostic Settings Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.



