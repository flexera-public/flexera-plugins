# GCP Cloud SQL Plugin

## Overview
The GCP Cloud SQL Plugin consumes the Google Cloud SQL API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to create, delete, and manage Cloud SQL resources.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
  - the `admin` role is needed to set/retrieve the RightScale Credentials for the GCP Cloud SQL API.
- GCP Service Account credentials
  - Refer to the Getting Started section for details on creating this account.
- The following RightScale Credentials must exist with the appropriate values
  - `GOOGLE_SQL_PLUGIN_ACCOUNT`
  - `GOOGLE_SQL_PLUGIN_PRIVATE_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)
- Enable the Google Cloud SQL API on your Project. Refer to [Google Documentation](https://cloud.google.com/sql/docs/mysql/admin-api/#activating_the_api) for more information.

## Getting Started
### Creating a GCP Service Account
This procedure will create a GCE Service account with the appropriate permissions to use this plugin.
1. Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documentation.
1. Follow the section named _Creating a service account_
    - Roles needs to include:
      - `Cloud SQL Admin`
    - Permissions can be restricted but may effect the permissions required to interact with certain resources with this plugin. Doing so is unsupported
   - Enabling G Suite Domain-wide Delegation is not required
   - Furnish a new private key selecting the JSON option
1. Download the Private Key and record the Service account ID (These will be stored in a RightScale Credential in a future step)
### Creating the RightScale Credentials
This procedure will setup the Credentials required for the GCE Plugin to interact with the GCE API
1. Review the [Credentials](http://docs.rightscale.com/cm/dashboard/design/credentials/index.html) documentation.
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_SQL_PLUGIN_ACCOUNT`
1. Paste the Service Account Id into the value of this credential and save
1. Extract/Copy the private_key from the JSON downloaded when you created the GCE Service Account
   - You will need to replace "\n" in the private_key with actual line returns to paste into the credential 
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_SQL_PLUGIN_PRIVATE_KEY`
1. Paste the private_key into the value of the credential making sure to replace "\n" with actual line returns and save

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `google_cloud_sql.rb` file located in this repository
 
## How to Use
The Cloud SQL Plugin has been packaged as `plugins/google_sql`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/google_sql"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Implementation Notes
- The Cloud SQL Plugin makes no attempt to support non-Cloud SQL resources. (i.e. Allow the passing the RightScale or other resources as arguments to a GCE resource.) 

## Supported Resources
### instances
#### Supported Fields

See Google documentation [here](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances#resource)

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | Instance Name | 
| settings | yes | user settings hash (see sub-value details [here](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances)) |
| database_version | no | The database engine type and version | 
| failover_replica | no | The name and status of the failover replica |
| master_instance_name | no | The name of the instance which will act as master in the replication setup |
| on_premises_configuration | no | on-prem instance configuration hash (see sub-value details [here](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances)) |
| region | no | The geographical region. Defaults to us-central or us-central1 depending on the instance type (First Generation or Second Generation/PostgreSQL) |
| replica_configuration | no | Failover replica and read replica configuration hash (see sub-value details [here](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances)) |

**Additional fields used in non-create actions:**
| Field Name | Action(s) |
|------------|-----------|
| max_results | `list()` |
| filter | `list()` |
| clone_context | `clone()` |
| failover_context | `failover()` |
| import_context | `import()` |
| export_context | `export()` |

#### Supported Outputs
- kind
- selfLink
- name
- connectionName
- etag
- project
- state
- backendType
- databaseVersion
- region
- currentDiskSize
- maxDiskSize
- settings
- serverCaCert
- ipAddresses
- instanceType
- masterInstanceName
- replicaNames
- failoverReplica
- ipv6Address
- serviceAccountEmailAddress
- onPremisesConfiguration
- replicaConfiguration
- suspensionReason

#### Usage
GCP Cloud SQL resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new SQL Instance
resource "gsql_instance", type: "cloud_sql.instances" do
  name join([$db_instance_prefix,"-",last(split(@@deployment.href, "/"))])
  database_version "MYSQL_5_7"
  region "us-central1"
  settings do {
    "tier" => "db-g1-small",
    "activationPolicy" => "ALWAYS",
    "dataDiskSizeGb" => "10",
    "dataDiskType" => "PD_SSD"
  } end 
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [insert](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/insert) | Supported |
| delete | [delete](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/delete) | Supported |
| get | [get](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/get) | Supported |
| list | [list](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/list) | Supported |
| update | [update](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/update) | Untested |
| patch | [patch](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/patch) | Untested |
| restart | [restart](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/restart) | Untested |
| clone | [clone](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/clone) | Untested |
| failover | [failover](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/failover) | Untested |
| import | [import](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/import) | Untested |
| export | [export](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/export) | Untested |
| get_replica | [get](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/get) | Supported |
| delete_replica | [delete](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/delete) | Supported |
| restore_backup | [restoreBackup](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/instances/restoreBackup) | Supported |

#### Supported Links

| Link | Resource Type | 
|------|---------------|
| databases() | databases |
| users() | users |

### databases
#### Supported Fields

See Google documentation [here](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/databases#resource)

| Field Name | Required? | Description |
|------------|-----------|-------------|
| instance_name | yes | SQL Instance name |
| charset | yes | MySQL charset value |
| name | yes | DB name |
| collation | yes | MySQL collation value |

#### Supported Outputs

- charset
- collation
- etag
- instance
- kind
- name
- project
- selfLink

#### Usage

```
# Creates a MySQL DB
resource "gsql_db", type: "cloud_sql.databases" do
  name $db_name
  instance_name @gsql_instance.name
  collation "utf8_general_ci"
  charset "utf8"
end 
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [insert](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/databases/insert) | Supported
| delete | [delete](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/databases/delete) | Supported
| get | [get](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/databases/get) | Supported
| list | [list](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/databases/list) | Supported
| update | [update](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/databases/update) | Untested

### users
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| instance_name | yes | SQL Instance name |
| host | no | host name from which the user can connect |
| name | yes | user name |
| password | yes | password for the user |


#### Supported Outputs

- etag
- host
- instance
- kind
- name
- project
- password

#### Usage

```
# Creates a MySQL user
resource "gsql_user", type: "cloud_sql.users" do
  name "frankel"
  instance_name @gsql_instance.name
  password "RightScale2017"
end 
```
**NOTE:** Due to an API limitation for this resource type, you will not be able to manipulate **users** resources via an RCL Resource Collection (ie. `@user.output`).  For this resource type, the best practice is to get **users** resources and then convert to an object, within a variable (ie. `$user`), and then parse the hash to retrieve outputs.

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [insert](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/users/insert) | Supported
| delete | [delete](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/users/delete) | Supported
| list | [list](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/users/list) | Supported
| update | [update](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/users/update) | Untested

### backup_runs
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| instance_name | yes | SQL Instance name |

#### Supported Outputs
- kind
- id
- selfLink
- instance
- description
- windowStartTime
- status
- type
- enqueuedTime
- startTime
- endTime
- error

#### Usage

```
# Backup as a resource
resource "gsql_backup", type: "cloud_sql.backup_runs" do
  instance_name @gsql_instance.name
end

# Backup as a definition
define create_database_backup(@gsql_instance) do
  cloud_sql.backup_runs.create(instance_name: @gsql_instance.name)
end
```

**NOTE:** Due to an API limitation for this resource type, you will not be able to manipulate **backup** resources via an RCL Resource Collection (ie. `@backup.output`).
 For this resource type, the best practice is to get **backup** resources and then convert to an object, within a variable (ie. `$backup`), and then parse the hash to retrieve outputs.

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [insert](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/backupRuns/insert) | Supported
| delete | [delete](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/backupRuns/delete) | Supported
| list | [list](https://cloud.google.com/sql/docs/mysql/admin-api/v1beta4/backupRuns/list) | Supported

## Examples
- [cloud_sql_test_cat.rb](./cloud_sql_test_cat.rb)
	
## Known Issues / Limitations
- User resources do no support a `get()` call which will make these resources behave a bit differently than standard resource types.  See the note in the Users resource documentation for more information.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GCE Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
