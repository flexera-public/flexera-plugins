# Azure Redis Cache Plugin

## Overview
The Azure Redis Cache Plugin integrates RightScale Self-Service with the basic functionality of the Azure Redis Cache service.

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
1. Update `azure_mysql_plugin.rb` Plugin with your Tenant ID. 
   - Replace "TENANT_ID" in `token_url "https://login.microsoftonline.com/TENANT_ID/oauth2/token"` with your Tenant ID
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `azure_mysql_plugin.rb` file located in this repository
 
## How to Use
The Azure Redis Cache Plugin has been packaged as `plugins/rs_azure_redis`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_redis"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure Redis Cache resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - cache
 - firewall_rule
 - patch_schedule

## Usage
```
#Creates a Redis Cache

parameter "subscription_id" do
  like $rs_azure_redis.subscription_id
end

resource "cache1", type: "rs_azure_redis.cache" do
  name join(["cache1-", last(split(@@deployment.href, "/"))])
  resource_group "CCtestresourcegroup"
  location "North Central US"
  properties do {
    "sku": {
      "name": "Premium",
      "family": "P",
      "capacity": 1
    },
    "enableNonSslPort": true,
    "shardCount": 1,
    "redisConfiguration": {
      "maxclients": "7500",
      "maxmemory-reserved": "200",
      "maxfragmentationmemory-reserved": "300",
      "maxmemory-delta": "200"
    }
  } end
  tags do {
      "ElasticCache" => "1"
  } end
end

resource "firewall_rule", type: "rs_azure_redis.firewall_rule" do
  name "samplefirewallrule"
  resource_group "CCtestresourcegroup"
  server_name @cache1.name
  properties do {
    "startIP" => "192.168.1.1",
    "endIP" => "192.168.1.254"
  } end
end

resource "patch_schedule", type: "rs_azure_redis.patch_schedule" do
  resource_group "CCtestresourcegroup"
  server_name @cache1.name
  properties do {
    "scheduleEntries": [
      {
        "dayOfWeek": "Monday",
        "startHourUtc": 12,
        "maintenanceWindow": "PT6H"
      },
      {
        "dayOfWeek": "Tuesday",
        "startHourUtc": 12
      }
    ]
  } end
end
```
## Resources
## cache
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the Redis server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties|Yes|Hash of Redis Cache properties (https://docs.microsoft.com/en-us/rest/api/redis/redis)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_Create) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_Get)| Supported |
| import | [Import](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_ImportData)| Untested |
| export | [Export](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_ExportData)| Untested |
| reboot | [forceReboot](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_ForceReboot)| Untested |
| listkeys | [listKeys](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_ListKeys)| Untested |
| regeneratekey | [RegenerateKey](https://docs.microsoft.com/en-us/rest/api/redis/redis#Redis_RegenerateKey)| Untested |

#### Supported Outputs
- "id"
- "name"
- "type"
- "location"
- "kind"
- "properties"
- "state"
- "provisioningState"
- "provisioningState"
- "redisVersion"
- "primaryKey"
- "secondaryKey"
- "sku"
- "enableNonSslPort"
- "redisConfiguration"
- "hostName"
- "port"
- "sslPort"

## firewall_rule
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the Redis Server FW Rule.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server to create the fw rule on|
|properties|Yes|Hash of FirewallRule properties (https://docs.microsoft.com/en-us/rest/api/redis/redisfirewallrule)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/redis/redisfirewallrule#FirewallRule_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/redis/redisfirewallrule#FirewallRule_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/redis/redisfirewallrule#FirewallRule_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "startIP"
- "endIP"

## patch_schedule
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|server_name|Yes|Server to create the patch schedule on|
|properties|Yes|Hash of Patch Schedule properties (https://docs.microsoft.com/en-us/rest/api/redis/patchschedules)|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create&update | [Create Or Update](https://docs.microsoft.com/en-us/rest/api/redis/patchschedules#PatchSchedules_CreateOrUpdate) | Supported |
| destroy | [Delete](https://docs.microsoft.com/en-us/rest/api/redis/patchschedules#PatchSchedules_Delete) | Supported |
| get | [Get](https://docs.microsoft.com/en-us/rest/api/redis/patchschedules#PatchSchedules_Get)| Supported |

#### Supported Outputs
- "id"
- "name"
- "type"
- "properties"
- "scheduleEntries"

## Implementation Notes
- The Azure Redis Cache Plugin makes no attempt to support non-Azure resources. (i.e. Allow the passing the RightScale or other resources as arguments to a Redis Cache resource.) 
 
Full list of possible actions can be found on the [Azure Redis Cache API Documentation](https://docs.microsoft.com/en-us/rest/api/redis/redis)
## Examples
Please review [redis_test_cat.rb](./redis_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure Redis Cache Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.
