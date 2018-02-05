# Azure PostgreSQL Database Plugin

## Overview
The Azure PostgreSQL Database Plugin integrates RightScale Self-Service with the basic functionality of the Azure PostgreSQL Database

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
1. Update `azure_pgsql_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_pgsql_plugin.rb` file located in this repository
 
## How to Use
The Azure PostgreSQL Database Plugin has been packaged as `plugins/rs_azure_pgsql`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_pgsql"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure PostgreSQL Database resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - sql_server
 - firewall_rule

## Usage
```
#Creates a PostgreSQL Server

parameter "subscription_id" do
  like $rs_azure_pgsql.subscription_id
end

resource "sql_server", type: "rs_azure_pgsql.pgsql_server" do
  name join(["my-sql-server-", last(split(@@deployment.href, "/"))])
  resource_group "CCtestresourcegroup"
  location "northcentralus"
  properties do {
    "administratorLogin" => "cloudsa",
    "administratorLoginPassword" => "RightScale2017",
    "storageMB" => 51200,
    "sslEnforcement" => "Enabled",
    "createMode" => "Default"
  } end
  sku do {
    "name" => "PGSQLB100",
    "tier" => "Basic",
    "capacity" => 100
  } end
  tags do {
    "ElasticServer" => "1"
  } end
end

resource "firewall_rule", type: "rs_azure_pgsql.firewall_rule" do
  name "sample-firewall-rule"
  resource_group "CCtestresourcegroup"
  location "northcentralus"
  server_name @sql_server.name
  properties do {
    "startIpAddress" => "0.0.0.1",
    "endIpAddress" => "0.0.0.1"
  } end
end
```
## Resources
## sql_server
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties|Yes|Hash of PostgreSQL Server properties (https://docs.microsoft.com/en-us/rest/api/postgresql/servers)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/postgresql/servers#Servers_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/postgresql/servers#Servers_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/postgresql/servers#Servers_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "version"
- "state"
- "properties"

## firewall_rule
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server to create the fw rule on|
|properties|Yes|Hash of FirewallRule properties (https://docs.microsoft.com/en-us/rest/api/postgresql/firewallrules)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/postgresql/firewallrules#FirewallRules_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/postgresql/firewallrules#FirewallRules_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/postgresql/firewallrules#FirewallRules_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "startIpAddress"
- "endIpAddress"

## Implementation Notes
- The Azure PostgreSQL Database Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an PostgreSQL resource.) 

 
Full list of possible actions can be found on the [Azure PostgreSQL Database API Documentation](https://docs.microsoft.com/en-us/rest/api/postgresql/)
## Examples
Please review [sql_test_cat.rb](./sql_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure PostgreSQL Database Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.