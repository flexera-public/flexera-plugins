# Azure Database for MySQL Plugin

## Overview
The Azure Database for MySQL Plugin integrates RightScale Self-Service with the basic functionality of the Azure Database for MySQL service.

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
1. Update `azure_mysql_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_mysql_plugin.rb` file located in this repository
 
## How to Use
The Azure Database for MySQL Plugin has been packaged as `plugins/rs_azure_mysql`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_mysql"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure MySQL Database resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - mysql_server
 - firewall_rule

## Usage
```
#Creates an MySQL Server

parameter "subscription_id" do
  like $rs_azure_sql.subscription_id
end

resource "sql_server", type: "rs_azure_sql.mysql_server" do
  name join(["my-mysql-server-", last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  location "Central US"
  properties do {
      "storageMB": 51200,
      "sslEnforcement": "Enabled",
      "createMode": "Default",
      "administratorLogin" => "superdbadmin",
      "administratorLoginPassword" => "RightScale2017!",
      "version" => "5.6"
  } end
  sku do {
      "name" => "MYSQLS3M100",
      "tier" => "Basic",
      "capacity" => 100
  } end
  tags do {
      "ElasticServer" => "1"
  } end
end

resource "firewall_rule", type: "rs_azure_sql.firewall_rule" do
  name "sample-firewall-rule"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  properties do {
    "startIpAddress" => "0.0.0.1",
    "endIpAddress" => "0.0.0.1"
  } end
end


```
## Resources
## mysql_server
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the MySQL server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties|Yes|Hash of SQL Server properties (https://docs.microsoft.com/en-us/rest/api/mysql/)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/mysql/servers#Servers_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/mysql/servers#Servers_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/mysql/servers#Servers_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "fullyQualifiedDomainName"
- "administratorLogin"
- "administratorLoginPassword"
- "version"
- "state"
- "sslEnforcement"
- "userVisibleState"

## firewall_rule
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server to create the fw rule on|
|properties|Yes|Hash of FirewallRule properties (https://docs.microsoft.com/en-us/rest/api/sql/firewallrules)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/firewallrules#FirewallRules_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/sql/firewallrules#FirewallRules_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/firewallrules#FirewallRules_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "startIpAddress"
- "endIpAddress"

## Implementation Notes
- The Azure Database for MySQL Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an MySQL resource.) 
 
Full list of possible actions can be found on the [Azure Database for MySQL API Documentation](https://docs.microsoft.com/en-us/rest/api/mysql/)
## Examples
Please review [mysql_test_cat.rb](./mysql_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure SQL Database Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.
