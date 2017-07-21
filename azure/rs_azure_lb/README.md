# Azure Load Balancer Plugin

## Overview
The Azure Load Balancer Plugin integrates RightScale Self-Service with the basic functionality of the Azure Load Balancer

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- Azure Service Principal (AKA Azure Active Directory Application) with the appropriate permissions to manage resources in the target subscription
- The following RightScale Credentials
  - `AZURE_APPLICATION_ID`
  - `AZURE_APPLICATION_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AzureRM Cloud credentials to your RightScale account (if not already completed)
1. Follow steps to [Create an Azure Active Directory Application](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#create-an-azure-active-directory-application)
1. Grant the Azure AD Application access to the necessary subscription(s)
1. [Retrieve the Application ID & Authentication Key](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
1. Create RightScale Credentials with values that match the Application ID (Credential name: `AZURE_APPLICATION_ID`) & Authentication Key (Credential name: `AZURE_APPLICATION_KEY`)
1. [Retrieve your Tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)
1. Update `azure_lb_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/AZURE_TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_lb_plugin.rb` file located in this repository
 
## How to Use
The Azure Load Balancer Plugin has been packaged as `plugins/rs_azure_lb`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_lb"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Load Balancer resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - load_balancer

## Usage
```
#Creates an load_balancer

parameter "subscription_id" do
  like $rs_azure_lb.subscription_id
end

parameter "resource_group" do
  type  "string"
  label "Resource Group"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_pub_lb", type: "rs_azure_lb.load_balancer" do
  name join(["my-pub-lb-", last(split(@@deployment.href, "/"))])
  resource_group "azure-example"
  location "Central US"
  frontendIPConfigurations do [
    {
     "name" => "ip1",
     "properties" => {
        "publicIPAddress" => {
           "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/publicIPAddresses/example"])
        }
      }
    }
  ] end

  backendAddressPools do [
    {
      "name" => "pool1" 
    }
  ] end

  loadBalancingRules do [
    {
      "name"=> "HTTP Traffic",
      "properties" => {
         "frontendIPConfiguration" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/frontendIPConfigurations/ip1"])
         },  
         "backendAddressPool" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/backendAddressPool/pool1"])
         },  
         "protocol" => "Http",
         "frontendPort" => 80,
         "backendPort" => 8080,
         "probe" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",$resource_group,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/probes/probe1"])
         },
         "enableFloatingIP" => true,
         "idleTimeoutInMinutes" => 4,
         "loadDistribution" => "Default"
      }
    }  
  ] end

  probes do [
    {
      "name" =>  "probe1",
      "properties" => {
        "protocol" =>  "Http",
        "port" =>  8080,
        "requestPath" =>  "/",
        "intervalInSeconds" =>  5,
        "numberOfProbes" =>  16
      }
    }
  ] end
end
```
## Resources
## load_balancer
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the load_balancer.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|frontendIPConfigurations|No|Object representing the Frontend IPs to be used for the Load Balancer|
|backendAddressPools|No|Collection of Backend Address Pools used by this Load Balancer|
|loadBalancingRules|No|Object collection representing the Load Balancing Rules for this Load Balancer|
|probes|No|Collection of Probe objects used in the Load Balancer|
|inboundNatPools|No|Defines an external port range for Inbound Nat to a single backend port on NICs associated with this Load Balancer. Inbound Nat Rules are created automatically for each NIC associated with the Load Balancer using an external port from this range. Defining an Inbound Nat Pool on your Load Balancer is mutually exclusive with defining Inbound Nat Rules. Inbound Nat Pools are referenced from Virtual Machine Scale Sets. NICs that are associated with individual Virtual Machines cannot reference an Inbound Nat Pool. They have to reference individual Inbound Nat Rules.|
|inboundNatRules|No|Collection of Inbound Nat Rules used by this Load Balancer. Defining Inbound Nat Rules on your Load Balancer is mutually exclusive with defining an Inbound Nat Pool. Inbound Nat Pools are referenced from Virtual Machine Scale Sets. NICs that are associated with individual Virtual Machines cannot reference an Inbound Nat Pool. They have to reference individual Inbound Nat Rules.|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/create-or-update-a-load-balancer#request) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/delete-a-load-balancer) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/get-information-about-a-load-balancer)| Supported |

#### Supported Outputs
- id
- name
- type
- location
- kind

## Implementation Notes
- The Azure Load Balancer Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an LB resource.) 

 
Full list of possible actions can be found on the [Azure Load Balancer API Documentation](https://docs.microsoft.com/en-us/rest/api/network/loadbalancer/)
## Examples
Please review [lb_test_cat.rb](./lb_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Load Balancer Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.