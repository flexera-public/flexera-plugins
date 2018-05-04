# Azure ARM Resource Plugin

## Overview
The Azure ARM Resource Plugin integrates RightScale Self-Service with the basic functionality of the Resources resource in the Azure API. 

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
1. Update `rs_azure_resource.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `rs_azure_resource.rb` file located in this repository
 
## How to Use
The ARM Resource Plugin has been packaged as `plugins/rs_azure_resource`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_resource"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Plugin Parameters
### subscription_id
There is a "subscription_id" Plugin Parameter in the ARM Template Plugin.  Recommended usage (where the `default` value matches your target Subscription ID):
```
parameter "subscription_id" do
  like $rs_azure_resource.subscription_id
  default "12345678-1234-1234-1234-123456789012"
end
```
**Note:** `default` is not a required field.  You could, instead, elect to populate this parameter at every CloudApp Launch.

## Supported Resources
None - This release only supports use of the plugin via RCL.

#### Supported Fields
N/A

#### Usage
N/A

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| update | [Create Or Update By Id](https://docs.microsoft.com/en-us/rest/api/resources/resources/createorupdatebyid) | Supported |
| updatebyid | [Update By Id](https://docs.microsoft.com/en-us/rest/api/resources/resources/updatebyid) | Supported |
| get | [Get By Id](https://docs.microsoft.com/en-us/rest/api/resources/resources/getbyid) | Supported |
| list | [List](https://docs.microsoft.com/en-us/rest/api/resources/resources/list) | Supported |
| listbyresourcegroup | [List By Resource Group](https://docs.microsoft.com/en-us/rest/api/resources/resources/listbyresourcegroup) | Supported |


## Examples
Please review [arm_resource_test_cat.rb](./arm_resource_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- This plugin only supports working with resources in RCL. It does not support provisioning CAT resources.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure ARM Resource Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.



