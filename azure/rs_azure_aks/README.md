# Azure Kubernetes Service Plugin

## Overview
The Azure Kubernetes Service Plugin integrates RightScale Self-Service with the basic functionality of the Azure Kubernetes Service
**WARNING: Do not use the enclosed ssh key for production **

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
1. Update `azure_aks_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_aks_plugin.rb` file located in this repository
 
## How to Use
The Azure Kubernetes Service Plugin has been packaged as `plugins/rs_azure_aks`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_aks"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Kubernetes Service resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - aks

## Usage
```

parameter "subscription_id" do
  like $rs_azure_aks.subscription_id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_resource_group", type: "rs_cm.resource_group" do
  cloud_href "/api/clouds/3526"
  name @@deployment.name
  description join(["aks resource group for ", @@deployment.name])
end

# https://github.com/Azure/azure-quickstart-templates/tree/master/101-aks
# https://github.com/Azure/azure-quickstart-templates/blob/master/101-aks/azuredeploy.parameters.json
resource "my_k8s", type: "rs_azure_aks.aks" do
  name join(["myc", last(split(@@deployment.href, "/"))])
  resource_group @my_resource_group.name
  location "Central US"
  properties do {
  "dnsPrefix" => join(["dnsprefix-", last(split(@@deployment.href, "/"))]),
   "orchestratorProfile" => {
      "orchestratorType" =>  "Kubernetes"
    },
    "servicePrincipalProfile" => {
      "clientId" => cred("AZURE_APPLICATION_ID"),
      "secret" => cred("AZURE_APPLICATION_KEY")
    },
 
    "agentPoolProfiles" =>  [
      {
        "name" =>  "agentpools",
        "count" =>  2,
        "vmSize" =>  "Standard_DS2",
        "dnsPrefix" => join(["dnsprefix-", last(split(@@deployment.href, "/"))]),
        "storageProfile" => 'ManagedDisks',
        "osType" => 'Linux'
      }
    ],
    "diagnosticsProfile" => {
      "vmDiagnostics" => {
          "enabled" =>  "false"
      }
    },
    "linuxProfile" => {
      "adminUsername" =>  "azureuser",
      "ssh" => {
        "publicKeys" =>  [
          {
            "keyData" =>  "change me"
          }
        ]
      }
    }
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler(@my_resource_group,@my_k8s) return @my_resource_group,@my_k8s do
  call start_debugging()
  provision(@my_resource_group)
  provision(@my_k8s)
  call stop_debugging()
end
```
## Resources
## aks
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the kubernetes service in the specified subscription and resource group.|
|resource_group|Yes|The name of the resource group.|
|location|Yes|Datacenter to launch in|
|properties|Yes| Properties of the aks service.(https://docs.microsoft.com/en-us/rest/api/aks/managedclusters/createorupdate)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create||update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/aks/managedclusters/createorupdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/aks/managedclusters/delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/aks/managedclusters/get)| Supported |

#### Supported Outputs
- id
- name
- type
- location
- sku
- properties
- state
- provisioningState

## Implementation Notes
- The Azure Kubernetes Service  Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an AKS resource.) 

 
Full list of possible actions can be found on the [Azure Kubernetes Service  API Documentation](https://docs.microsoft.com/en-us/rest/api/aks/)
## Examples
Please review [aks_test_cat.rb](./azure_aks_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Kubernetes Service Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
