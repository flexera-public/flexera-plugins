# GCP Bigtable Plugin

## Overview
The GCP Bigtable Plugin consumes the Google Bigtable Admin API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to create, delete, and manage Bigtable resources.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
  - the `admin` role is needed to set/retrieve the RightScale Credentials for the GCP Bigtable Admin API.
- GCP Service Account credentials
  - Refer to the Getting Started section for details on creating this account.
- The following RightScale Credentials must exist with the appropriate values
  - `GOOGLE_BIGTABLE_PLUGIN_ACCOUNT`
  - `GOOGLE_BIGTABLE_PLUGIN_PRIVATE_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started
### Creating a GCP Service Account
This procedure will create a GCE Service account with the appropriate permissions to use this plugin.
1. Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documentation.
1. Follow the section named _Creating a service account_
    - Roles needs to include:
      - `bigtable.admin`
    - Permissions can be restricted but may effect the permissions required to interact with certain resources with this plugin. Doing so is unsupported
   - Enabling G Suite Domain-wide Delegation is not required
   - Furnish a new private key selecting the JSON option
1. Download the Private Key and record the Service account ID (These will be stored in a RightScale Credential in a future step)
### Creating the RightScale Credentials
This procedure will setup the Credentials required for the Bigtable Plugin to interact with the Bigtable Admin API
1. Review the [Credentials](http://docs.rightscale.com/cm/dashboard/design/credentials/index.html) documentation.
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_BIGTABLE_PLUGIN_ACCOUNT`
1. Paste the Service Account Id into the value of this credential and save
1. Extract/Copy the private_key from the JSON downloaded when you created the GCE Service Account
   - You will need to replace "\n" in the private_key with actual line returns to paste into the credential 
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_BIGTABLE_PLUGIN_PRIVATE_KEY`
1. Paste the private_key into the value of the credential making sure to replace "\n" with actual line returns and save

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `gcp_bigtable_plugin.rb` file located in this repository
 
## How to Use
The Bigtable Plugin has been packaged as `plugins/bigtable`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/bigtable"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Implementation Notes
- The Bigtable Plugin makes no attempt to support non-Bigtable resources. (i.e. Allow the passing the RightScale or other resources as arguments to a Bigtable resource.) 
- The Bigtable Plugin only interacts with the [Bigtable REST Admin API](https://cloud.google.com/bigtable/docs/reference/admin/rest/) and does not interact with any other Google Cloud API.

## Supported Resources
 - instances
 - clusters
 - tables

## Usage
```
resource "my_instance", type: "bigtable.instances" do
    instance_id join(["rs-",last(split(@@deployment.href, "/"))])
    instance do {
        "displayName" => "rs-instance",
        "type" => "PRODUCTION"
    } end
    clusters do {
      "my_cluster" => {
        "location" => join(["projects/", $google_project, "/locations/us-central1-c"]),
        "serveNodes" => 3,
        "defaultStorageType => "HDD"
      }
    } end 
end 

resource "my_cluster", type: "bigtable.clusters" do
    instance_id join(["rs-",last(split(@@deployment.href, "/"))])
    cluster_id join(["rs-cluster-",last(split(@@deployment.href, "/"))])
end

resource "my_table", type: "bigtable.tables" do
    instance_id join(["rs-",last(split(@@deployment.href, "/"))])
    table_id join(["table",last(split(@@deployment.href, "/"))])
end
```

## Resources
### instances
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| instance_id | Yes | The UID of the Bigtable instance |
| instance | Yes | Object containing the necessary Bigtable Instance fields. See [documentation](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances#Instance) for more deatil | 
| clusters | Yes (but not required via CAT, can be set via RCL) | Object containing the necessary Bigtable Cluster fields. See [documentation](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters#Cluster) for more deatil | 

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [Create](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/create) | Supported |
| destroy | [Delete](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/delete) | Supported |
| get & show | [Get](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/get)| Supported |
| list | [List](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/list) | Untested | 
| update | [Update](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/update) | Untested |

#### Supported Outputs
- name
- displayName
- state
- type

### clusters
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| instance_id | Yes | The UID of the associated Bigtable instance | |
| cluster_id | Yes | The UID of the Bigtable cluster |
| location | Yes | Zone that the Bigtable cluster should be created in. |
| serve_nodes | Yes | Number of nodes allocated to the cluster |
| default_storage_type | No | The type of storage used by the cluster |  

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [Create](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/create) | Untested |
| destroy | [Delete](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/delete) | Supported |
| get & show | [Get](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/get)| Supported |
| list | [List](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.clusters/list) | Untested | 
| update | [Update](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances/update) | Untested |

#### Supported Outputs
- name
- location
- state
- serveNodes
- defaultStorageType

### tables
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| instance_id | Yes | The UID of the associated Bigtable instance |
| table_id | Yes | The UID of the Bigtable table | 
| table | No | Object containing the necessary Bigtable Table fields. See [documentation](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables#Table) for more deatil | 
| initial_splits | No | Object containing a list of row keys that will be used to split the table into several tables. See [documentation](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/create#Split) for more detail. |

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [Create](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/create) | Supported |
| destroy | [Delete](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/delete) | Supported |
| get & show | [Get](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/get)| Supported |
| list | [List](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/list) | Untested | 
| drop_rows | [dropRowRange](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/dropRowRange) | Untested |
| modify_families | [modifyColumnFamilies](https://cloud.google.com/bigtable/docs/reference/admin/rest/v2/projects.instances.tables/modifyColumnFamilies) | Untested |

#### Supported Outputs
- name
- location
- state
- serveNodes
- defaultStorageType

## Examples
Please review [bigtable_test_cat.rb](./bigtable_test_cat.rb) for a basic example implementation.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GCP Bigtable Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
