# Azure ARM Template Plugin

## Overview
The Azure ARM Template Plugin integrates RightScale Self-Service with the basic functionality of the Deployments resource in the Azure API. 

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
1. Update `rs_azure_template.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `rs_azure_template.rb` file located in this repository
 
## How to Use
The ARM Template Plugin has been packaged as `plugins/rs_azure_template`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_template"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Plugin Parameters
### subscription_id
There is a "subscription_id" Plugin Parameter in the ARM Template Plugin.  Recommended usage (where the `default` value matches your target Subscription ID):
```
parameter "subscription_id" do
  like $rs_azure_template.subscription_id
  default "12345678-1234-1234-1234-123456789012"
end
```
**Note:** `default` is not a required field.  You could, instead, elect to populate this parameter at every CloudApp Launch.

## Supported Resources
### deployment

#### Supported Fields
**Note:** There are many possible configurations when defining a `deployment` resource.  More detailed API documentation is available [here](https://docs.microsoft.com/en-us/rest/api/resources/deployments).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | Deployment name | 
| resource_group | yes | Name of resource group in which to launch the Deployment | 
| properties | yes | Hash of Deployment properties (see examples and Azure API documentation for more details) | 

#### Supported Outputs
- id
- name
- provisioningState
- correlationId
- timestamp
- outputs
- providers
- dependencies
- templateLink
- parametersLink
- template
- parameters
- mode

#### Usage
Deployment resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new Azure Deployment from an ARM Template
resource "my_deployment", type: "rs_azure_template.deployment" do
  name join(["SS-test", last(split(@@deployment.href, "/"))])
  resource_group "RightScale-Testing"
  properties do {
    "templateLink" => { 
      "uri" => "https://rightscaletesting11.blob.core.windows.net/rs-plugin-template-test/template.json" },
    "parametersLink" => {
      "uri" => "https://rightscaletesting11.blob.core.windows.net/rs-plugin-template-test/parameters.json" },
    "mode" => "Incremental"
  } end
end 
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create & update | [CreateOrUpdateDeployment](https://docs.microsoft.com/en-us/rest/api/resources/deployments#Deployments_CreateOrUpdate) | Supported |
| destroy | [DeleteDeployment](https://docs.microsoft.com/en-us/rest/api/resources/deployments#Deployments_Delete) | Supported |
| get | [GetDeployment](https://docs.microsoft.com/en-us/rest/api/resources/deployments#Deployments_Get) | Supported |
| list | [ListDeploymentByResourceGroup](https://docs.microsoft.com/en-us/rest/api/resources/deployments#Deployments_ListByResourceGroup) | Supported |
| validate_template | [ValidateTemplate](https://docs.microsoft.com/en-us/rest/api/resources/deployments#Deployments_Validate) | Supported |



## Examples
Please review [ARM_template_test_CAT.rb](./ARM_template_test_CAT.rb) for a basic example implementation.
	
## Known Issues / Limitations
- When attempting to pass the template in-line (ie. by using the "template" key in the "properties" hash, Azure refuses the "$schema" node due to request encoding.  It is recommended to host your ARM Templates in Blob Storage.  This limitation does not affect passing parameters in-line, as seen in the example CAT. 
- Due to the way that Azure handles the Delete Deployment API call, the underlying resources are not automatically deleted when a `destory()` action is called on a rs_azure_template.deployment resource


## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure ARM Template Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.



