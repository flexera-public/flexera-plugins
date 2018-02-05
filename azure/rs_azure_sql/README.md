# Azure SQL Database Plugin

## Overview
The Azure SQL Database Plugin integrates RightScale Self-Service with the basic functionality of the Azure SQL Database

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
The Azure SQL Database Plugin has been packaged as `plugins/rs_azure_sql`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_sql"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure SQL Database resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - sql_server
 - databases
 - transparent_data_encryption
 - firewall_rule
 - elastic_pool
 - auditing_policy
 - security_policy

## Usage
```
#Creates an SQL Server and DB

parameter "subscription_id" do
  like $rs_azure_sql.subscription_id
end

resource "sql_server", type: "rs_azure_sql.sql_server" do
  name join(["my-sql-server-", last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  location "Central US"
  properties do {
      "version" => "12.0",
      "administratorLogin" =>"rightscale",
      "administratorLoginPassword" => "RightScale2017"
  } end
end

resource "database", type: "rs_azure_sql.databases" do
  name "sample-database"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

resource "transparent_data_encryption", type: "rs_azure_sql.transparent_data_encryption" do
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "status" => "Disabled"
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

resource "elastic_pool", type: "rs_azure_sql.elastic_pool" do
  name "sample-elastic-pool"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

resource "auditing_policy", type: "rs_azure_sql.auditing_policy" do
  name "sample-auditing-policy"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "state" => "Enabled",
    "storageAccountAccessKey" => cred("storageAccountAccessKey"),
    "storageEndpoint" => cred("storageEndpoint")
  } end
end

resource "security_policy", type: "rs_azure_sql.security_policy" do
  name "sample-security-policy"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "state" => "Enabled",
    "storageAccountAccessKey" => cred("storageAccountAccessKey"),
    "storageEndpoint" => cred("storageEndpoint")
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
|properties|Yes|Hash of SQL Server properties (https://docs.microsoft.com/en-us/rest/api/sql/servers)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/servers#Servers_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/sql/servers#Servers_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/servers#Servers_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "fullyQualifiedDomainName"
- "administratorLogin"
- "administratorLoginPassword"
- "externalAdministratorLogin"
- "externalAdministratorSid"
- "version"
- "state"

## databases
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server to create db on|
|properties|Yes|Hash of Database properties (https://docs.microsoft.com/en-us/rest/api/sql/databases)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/databases#Database_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/sql/databases#Database_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/databases#Database_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "edition"
- "status"
- "serviceLevelObjective"
- "collation"
- "creationDate"
- "maxSizeBytes"
- "currentServiceObjectiveId"
- "requestedServiceObjectiveId"
- "requestedServiceObjectiveName"
- "sampleName"
- "defaultSecondaryLocation"
- "earliestRestoreDate"
- "elasticPoolName"
- "containmentState"
- "readScale"
- "failoverGroupId"

## transparent_data_encryption
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server the database is on|
|database_name|Yes|database to configure encryption setting on|
|properties|Yes|Hash of Transparent Data Encryption properties (https://docs.microsoft.com/en-us/rest/api/sql/databases#Databases_CreateOrUpdateTransparentDataEncryptionConfiguration)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/databases#Databases_CreateOrUpdateTransparentDataEncryptionConfiguration) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/databases#Databases_GetTransparentDataEncryptionConfiguration)| Supported |

#### Supported Outputs
- "id"
- "name"
- "status"
- "percentComplete"

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
- "location"
- "kind"
- "startIpAddress"
- "endIpAddress"

## elastic_pool
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server to create the elastic pool  on|
|properties|Yes|Hash of ElasticPools properties (https://docs.microsoft.com/en-us/rest/api/sql/elasticpools)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/elasticpools#ElasticPools_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/sql/elasticpools#ElasticPools_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/elasticpools#ElasticPools_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "creationDate"
- "edition" do
- "state"
- "dtu"
- "databaseDtuMin"
- "databaseDtuMax"
- "storageMB"

## auditing_policy
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server the database is on|
|database_name|Yes|database to configure auditing-policy on|
|properties|Yes|Hash of Auditing Policy properties (https://docs.microsoft.com/en-us/rest/api/sql/blob%20auditing%20policies)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/blob%20auditing%20policies#Databases_CreateOrUpdateBlobAuditingPolicy) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/blob%20auditing%20policies#Databases_GetBlobAuditingPolicy)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "state"
- "storageEndpoint"
- "storageAccountAccessKey"
- "retentionDays"
- "storageAccountSubscriptionId"
- "isStorageSecondaryKeyInUse"
- "auditActionsAndGroups"

## security_policy
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server the database is on|
|database_name|Yes|database to security_policy on|
|properties|Yes|Hash of Security Policy properties (https://docs.microsoft.com/en-us/rest/api/sql/database%20security%20policies)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/sql/database%20security%20policies#Databases_CreateOrUpdateThreatDetectionPolicy) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/sql/database%20security%20policies#Databases_GetThreatDetectionPolicy)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "state"
- "emailAccountAdmins"
- "emailAddresses"
- "disabledAlerts"
- "retentionDays"
- "storageAccountAccessKey"
- "storageEndpoint"
- "useServerDefault"

## Implementation Notes
- The Azure SQL Database Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to an SQL resource.) 

 
Full list of possible actions can be found on the [Azure SQL Database API Documentation](https://docs.microsoft.com/en-us/rest/api/sql/)
## Examples
Please review [sql_test_cat.rb](./sql_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure SQL Database Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.