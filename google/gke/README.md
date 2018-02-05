# Google Container Engine (GKE) Plugin

## Overview
The GKE Plugin consumes the Google Container Engine API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to create, delete, and manage GKE resources.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
  - the `admin` role is needed to set/retrieve the RightScale Credentials for the GKE API.
- GCP Service Account credentials
  - Refer to the Getting Started section for details on creating this account.
- The following RightScale Credentials must exist with the appropriate values
  - `GOOGLE_CONTAINER_ENGINE_ACCOUNT`
  - `GOOGLE_CONTAINER_ENGINE_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started
### Creating a GCP Service Account
This procedure will create a GCE Service account with the appropriate permissions to use this plugin.
1. Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documentation.
1. Follow the section named _Creating a service account_
    - Roles needs to include:
      - `Kubernetes Engine Admin`
      - `Service Account User`
    - Permissions can be restricted but may effect the permissions required to interact with certain resources with this plugin. Doing so is unsupported
   - Enabling G Suite Domain-wide Delegation is not required
   - Furnish a new private key selecting the JSON option
1. Download the Private Key and record the Service account ID (These will be stored in a RightScale Credential in a future step)
### Creating the RightScale Credentials
This procedure will setup the Credentials required for the Bigtable Plugin to interact with the Bigtable Admin API
1. Review the [Credentials](http://docs.rightscale.com/cm/dashboard/design/credentials/index.html) documentation.
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_CONTAINER_ENGINE_ACCOUNT`
1. Paste the Service Account Id into the value of this credential and save
1. Extract/Copy the private_key from the JSON downloaded when you created the GCE Service Account
   - You will need to replace "\n" in the private_key with actual line returns to paste into the credential 
1. Create a credential in the desired RightScale Account with the name of `GOOGLE_CONTAINER_ENGINE_KEY`
1. Paste the private_key into the value of the credential making sure to replace "\n" with actual line returns and save

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `gke_plugin.rb` file located in this repository
 
## How to Use
The GKE Plugin has been packaged as `plugins/gke`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/gke"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Implementation Notes
- The GKE Plugin makes no attempt to support non-GKE resources. (i.e. Allow the passing the RightScale or other resources as arguments to a GKE resource.) 
- The GKE Plugin only interacts with the [GKE REST Admin API](https://cloud.google.com/container-engine/reference/rest/) and does not interact with any other Google Cloud API.

## Supported Resources
 - clusters

## Resources
### clusters
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| zone | Yes | The name of the Google Compute Engine zone in which the cluster resides. |
| cluster | Yes | Object containing the necessary GKE Cluster fields. See [documentation](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters#Cluster) for more deatil | 
| update | Only required for `update()` action | Object containing the necessary GKE Cluster fields. See [documentation](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters#Cluster) for more deatil | 

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [Create](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters/create) | Supported |
| destroy | [Delete](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters/delete) | Supported |
| get | [Get](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters/get)| Supported |
| list | [List](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters/list) | Untested | 
| update | [Update](https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters/update) | Untested |

#### Supported Outputs
- name
- description
- initialNodeCount 
- loggingService
- monitoringService
- network
- clusterIpv4Cidr
- subnetwork
- locations
- enableKubernetesAlpha
- resourceLabels
- labelFingerprint
- selfLink
- zone
- endpoint
- initialClusterVersion
- currentMasterVersion
- currentNodeVersion 
- createTime
- status
- statusMessage
- nodeIpv4CidrSize
- servicesIpv4Cidr
- instanceGroupUrls
- currentNodeCount
- expireTime
- nodeConfig
- masterAuth
- addonsConfig
- nodePools
- legacyAbac
- networkPolicy
- ipAllocationPolicy
- masterAuthorizedNetworksConfig

## Examples
Please review [gke_test_cat.rb](./gke_test_cat.rb) for a basic example implementation.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GKE Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
