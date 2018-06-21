# Azure Key Vault Plugin

## Overview
The Azure Key Vault Plugin integrates RightScale Self-Service with the basic functionality of the Azure Key Vault API.

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
1. Update `azure_keyvault_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_keyvault_plugin.rb` file located in this repository
 
## How to Use
The Azure Key Vault Plugin has been packaged as `plugins/rs_azure_keyvault`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_keyvault"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Key Vault resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - vaults

## Usage
```
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
    "tenantId" => "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  } end 
end 
```

## Resources
### vaults 
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the Key Vault in the specified subscription and resource group.|
|resource_group|Yes|The name of the resource group.|
|location|Yes|Datacenter to launch in|
|properties|Yes| Properties of the [Key Vault object](https://docs.microsoft.com/en-us/rest/api/keyvault/Vaults/CreateOrUpdate#definitions_vaultproperties)|
|tags|No|Tag values|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create & update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/keyvault/vaults/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/keyvault/vaults/delete) | Supported |
| get & show | [Get](https://docs.microsoft.com/en-us/rest/api/keyvault/vaults/get)| Supported |
| list by resource group | [List By Resource Group](https://docs.microsoft.com/en-us/rest/api/keyvault/keyvaultpreview/vaults/listbyresourcegroup) | Supported |

#### Supported Outputs
- id
- name
- location
- tags
- properties
- type
- access_policies
- create_mode
- enable_soft_delete
- enabled_for_deployment
- enabled_for_disk_encryption
- enabled_for_template_deployment
- sku
- vault_uri

## Implementation Notes
- The Azure Key Vault Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to a Key Vault resource.) 

 
Full list of possible actions can be found on the [Azure Key Vault API Documentation](https://docs.microsoft.com/en-us/rest/api/keyvault/)

## Examples
Please review [keyvault_test_cat.rb](./keyvault_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports Vault resources due to API endpoint challenges with Key/Cert/Secret resources

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Key Vault Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
