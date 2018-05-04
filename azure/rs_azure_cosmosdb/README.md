# Azure CosmosDB Plugin

## Overview
The Azure CosmosDB Plugin integrates RightScale Self-Service with the basic functionality of the Azure CosmosDB Account API.

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
1. Update `azure_cosmosdb_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_cosmosdb_plugin.rb` file located in this repository
 
## How to Use
The Azure CosmosDB Plugin has been packaged as `plugins/rs_azure_cosmosdb`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_cosmosdb"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure CosmosDB resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - db_account

## Usage
```
resource "cosmosdb", type: "rs_azure_cosmosdb.db_account" do
  name join(["cosmosdb-",last(split(@@deployment.href, "/"))])
  resource_group @rg.name
  location "centralus"
  kind "GlobalDocumentDB"
  properties do {
    "databaseAccountOfferType" => "Standard",
    "locations" => [
      {
        "failoverPriority" => "0",
        "locationName" => "westus"
      },
      {
        "failoverPriority" => "1",
        "locationName" => "eastus"
      },
    ],
    "consistencyPolicy" => {
      "defaultConsistencyLevel" => "Session",
      "maxIntervalInSeconds" => "5",
      "maxStalenessPrefix" => "100"
    }
  } end 
  tags do {
      "defaultExperience" => "DocumentDB",
      "costcenter" => "12345",
      "envrionment" => "dev",
      "department" => "engineering"
  } end
end 
```

## Resources
### vaults 
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the CosmosDB Account in the specified subscription and resource group.|
|resource_group|Yes|The name of the resource group.|
|location|Yes|Datacenter to launch in|
|kind|Yes|Indicates the type of database account. This can only be set at database account creation.|
|properties|Yes| Properties of the [CosmosDB Account object](https://docs.microsoft.com/en-us/rest/api/cosmos-db-resource-provider/databaseaccounts/createorupdate#databaseaccount)|
|tags|No|Tag values|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create & update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/cosmos-db-resource-provider/databaseaccounts/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/cosmos-db-resource-provider/databaseaccounts/delete) | Supported |
| get & show | [Get](https://docs.microsoft.com/en-us/rest/api/cosmos-db-resource-provider/databaseaccounts/get)| Supported |

#### Supported Outputs
- id
- name
- location
- tags
- properties
- type
- kind
- provisioningState
- ipRangeFilter
- isVirtualNetworkFilterEnabled
- databaseAccountOfferType
- consistencyPolicy
- writeLocations
- readLocations
- failoverPolicies
- virtualNetworkRules

## Implementation Notes
- The Azure CosmosDB Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to a CosmosDB resource.) 

 
Full list of possible actions can be found on the [Azure CosmosDB Accounts API Documentation](https://docs.microsoft.com/en-us/rest/api/cosmos-db-resource-provider/databaseaccounts)

## Examples
Please review [cosmosdb_test_cat.rb](./cosmosdb_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports Database Account resources due to API endpoint challenge with Database resources

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The Azure CosmosDB Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
