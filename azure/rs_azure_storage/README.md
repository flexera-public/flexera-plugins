# Azure Storage Account Plugin

## Overview
The Azure Storage Account Plugin integrates RightScale Self-Service with the basic functionality of the Azure Storage Account

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
1. Update `azure_storage_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_storage_plugin.rb` file located in this repository
 
## How to Use
The Azure Storage Account Plugin has been packaged as `plugins/rs_azure_storage`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_storage"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Storage Account resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - storage_account

## Usage
```

parameter "subscription_id
  like $rs_azure_storage.subscription_id
end

permission "read_creds
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_placement_group", type: "placement_group
  name join(["mypg", last(split(@@deployment.href, "/"))])
  description "test placement group"
  cloud "AzureRM Central US"
  cloud_specific_attributes do {
    "account_type" => "Standard_LRS"
  } end
end

operation "launch
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler(@my_placement_group) return @my_placement_group do
  provision(@my_placement_group)
  @pg_st_acct = rs_azure_storage.storage_account.show(name: @my_placement_group.name, resource_group: @@deployment.name )
  $pgstkeys = @pg_st_acct.list_keys()
  $s_pgstkeys = to_s($pgstkeys)
  call sys_log.detail("pgst:" + $s_pgstkeys)
end
```
## Resources
## storage_account
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the storage_account The name of the storage account within the specified resource group. Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only.|
|resource_group|Yes|Name of resource group in which to create the storage_account|
|location|Yes|Datacenter to launch in|
|sku|Yes|Required. Gets or sets the sku name
|properties|Yes| Hash of storage_account properties(https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts#StorageAccounts_Create)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create| [Create](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/create) | Supported |
| update | [Update](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/update) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/getproperties)| Supported |
| show| [Get](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/getproperties)| Supported |
| list_keys| [Post] (https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/listkeys)| Supported |
#### Supported Outputs
- id
- name
- type
- location
- sku
- properties
- state
- provisioningState
- primaryEndpoints
- primaryLocation
- statusOfPrimary
- lastGeoFailoverTime
- secondaryLocation
- statusOfSecondary
- creationTime
- customDomain
- secondaryEndpoints
- encryption
- accessTier
- supportsHttpsTrafficOnly


## Implementation Notes
- The Azure Storage Account Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an SA resource.) 

 
Full list of possible actions can be found on the [Azure Storage Account API Documentation](https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts)
## Examples
Please review [storage_test_cat.rb](./storage_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Storage Account Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.