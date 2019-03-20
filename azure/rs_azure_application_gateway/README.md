# Azure Application Gateway Plugin

## Overview
The Azure Application Gateway Plugin integrates RightScale Self-Service with the basic functionality.

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
1. Update `rs_azure_application_gateway.rb` Plugin with your Tenant ID.
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `rs_azure_application_gateway.rb` file located in this repository

## How to Use
The Azure Application Gateway Plugin has been packaged as `plugins/rs_azure_application_gateway`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_application_gateway"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Application Gateway resource can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - rs_azure_application_gateway.gateway

## Usage
For and example of how to use the plugin in your CAT review the [application_gateway_cat.rb](./application_gateway_cat.rb) for a reference

## Resources
## rs_azure_application_gateway.gateway
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the applicaton gateway.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties|Yes|The properties to configure the application gateway.  Refer to the example CAT or the Azure Api.|
|tags|No|Create Azure tags on the Application Gateway|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/application-gateway/applicationgateways/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/application-gateway/applicationgateways/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/application-gateway/applicationgateways/get)| Supported |

#### Supported Outputs
- id
- name
- type
- location
- kind

## Examples
Please review
- [application_gateway_cat.rb](./application_gateway_cat.rb) for a basic application gateway reference


## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Networking Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
