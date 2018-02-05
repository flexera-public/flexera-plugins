# GCE Plugin
## Notes
- Some of the resources in this plugin have not been tested. See the [Supported Resources](#supported-resources) section for details.
- Due to the nature and scope of this plugin, not all use cases may be supported as is. Please see the [Getting Help](#getting-help) section for details on requesting additional functionality.

## Overview
The GCE Plugin consumes the Google Compute v1 API and exposes the supported resources to RightScale SelfService. This allows for easy extension of a SelfService Cloud Application to use GCE resources not natively supported in RightScale.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- Admin rights to a RightScale account with SelfService enabled
  - Admin is needed to set/retrieve the RightScale Credentials for the GCE API.
- GCE Service Account credentials
  - Refer to the Getting Started section for details on creating this account.
- The following RightScale Credentials must exist with the appropriate values
  - `GCE_PLUGIN_ACCOUNT`
  - `GCE_PLUGIN_PRIVATE_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started
### Creating a GCE Service Account
This procedure will create a GCE Service account with the appropriate permissions to use this plugin.
1. Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documenatation.
1. Follow the section named _Creating a service account_
    - Roles needs to include:
      - Compute Instance Admin (beta)
      - Compute Network Admin
      - Compute Security Admin
    - Permissions can be restricted but may effect the permissions required to interact with certain resources with this plugin. Doing so is unsupported
   - Enabling G Suite Domain-wide Delegation is not required
   - Furnish a new private key selecting the JSON option
1. Download the Private Key and record the Service account ID (These will be stored in a RightScale Credential in a future step)
### Creating the RightScale Credentials
This procedure will setup the Credentials required for the GCE Plugin to interact with the GCE API
1. Review the [Credentials](http://docs.rightscale.com/cm/dashboard/design/credentials/index.html) documentation.
1. Create a credential in the desired RightScale Account with the name of `GCE_PLUGIN_ACCOUNT`
1. Paste the Service Account Id into the value of this credential and save
1. Extract/Copy the private_key from the JSON downloaded when you created the GCE Service Account
   - You will need to replace "\n" in the private_key with actual line returns to paste into the credential 
1. Create a credential in the desired RightScale Account with the name of `GCE_PLUGIN_PRIVATE_KEY`
1. Paste the private_key into the value of the credential making sure to replace "\n" with actual line returns and save

## Installation
1. Be sure your RightScale account is SelfService enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate SelfService portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `gce_plugin.rb` file located in this repository
 
## How to Use
The GCE Plugin has been packaged as `plugin/gce`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/gce"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

GCE resources can now be created by specifying a resource declaration with the desired fields. See the Supported Resources section for a full list.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a globalAddress
resource "my_address", type: "gce.globalAddress" do
  name "gce_plugin_address"
  description "Example address created by the GCE Plugin"
end
```

## Implementation Notes
- The GCE Plugin makes no attempt to support non-GCE resources. (i.e. Allow the passing the RightScale or other resources as arguments to a GCE resource.) 
 - The most common example might be to pass a RightScale instance as an argument to add to a GCE instancePool or similar. Support for this functionality will need to be implemented in the application CAT.

## Supported Resources
| ResourceName | Type | Support Level |
|--------------|:----:|:-------------:|
| [Addresses](https://cloud.google.com/compute/docs/reference/latest/addresses) | gce.addresses | Supported |
| [Autoscalers](https://cloud.google.com/compute/docs/reference/latest/autoscalers) | gce.autoscalers | Untested |
| [Backendbuckets](https://cloud.google.com/compute/docs/reference/latest/backendBuckets) | gce.backendBuckets | Untested |
| [Backendservices](https://cloud.google.com/compute/docs/reference/latest/backendServices) | gce.backendServices | Supported |
| [Disktypes](https://cloud.google.com/compute/docs/reference/latest/diskTypes) | gce.diskTypes | Untested |
| [Disks](https://cloud.google.com/compute/docs/reference/latest/disks) | gce.disks | Untested |
| [Firewalls](https://cloud.google.com/compute/docs/reference/latest/firewalls) | gce.firewalls | Untested |
| [Forwardingrules](https://cloud.google.com/compute/docs/reference/latest/forwardingRules) | gce.forwardingRules | Supported |
| [Globaladdresses](https://cloud.google.com/compute/docs/reference/latest/globalAddresses) | gce.globalAddresses | Supported |
| [Globalforwardingrules](https://cloud.google.com/compute/docs/reference/latest/globalForwardingRules) | gce.globalForwardingRules | Supported |
| [Globaloperations](https://cloud.google.com/compute/docs/reference/latest/globalOperations) | gce.globalOperations | Supported |
| [Healthchecks](https://cloud.google.com/compute/docs/reference/latest/healthChecks) | gce.healthChecks | Supported |
| [Httphealthchecks](https://cloud.google.com/compute/docs/reference/latest/httpHealthChecks) | gce.httpHealthChecks | Supported |
| [Httpshealthchecks](https://cloud.google.com/compute/docs/reference/latest/httpsHealthChecks) | gce.httpsHealthChecks | Untested |
| [Images](https://cloud.google.com/compute/docs/reference/latest/images) | gce.images | Untested |
| [Instancegroupmanagers](https://cloud.google.com/compute/docs/reference/latest/instanceGroupManagers) | gce.instanceGroupManagers | Untested |
| [Instancegroups](https://cloud.google.com/compute/docs/reference/latest/instanceGroups) | gce.instanceGroups | Untested |
| [Instancetemplates](https://cloud.google.com/compute/docs/reference/latest/instanceTemplates) | gce.instanceTemplates | Untested |
| [Instances](https://cloud.google.com/compute/docs/reference/latest/instances) | gce.instances | Tested |
| [Licenses](https://cloud.google.com/compute/docs/reference/latest/licenses) | gce.licenses | Untested |
| [Machinetypes](https://cloud.google.com/compute/docs/reference/latest/machineTypes) | gce.machineTypes | Untested |
| [Networks](https://cloud.google.com/compute/docs/reference/latest/networks) | gce.networks | Supported |
| [Globaloperations](https://cloud.google.com/compute/docs/reference/latest/globalOperations) | gce.globalOperations | Supported |
| [Projects](https://cloud.google.com/compute/docs/reference/latest/projects) | gce.projects | Untested |
| [Regionautoscalers](https://cloud.google.com/compute/docs/reference/latest/regionAutoscalers) | gce.regionAutoscalers | Untested |
| [Regionbackendservices](https://cloud.google.com/compute/docs/reference/latest/regionBackendServices) | gce.regionBackendServices | Supported |
| [Regioninstancegroupmanagers](https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroupManagers) | gce.regionInstanceGroupManagers | Untested |
| [Regioninstancegroups](https://cloud.google.com/compute/docs/reference/latest/regionInstanceGroups) | gce.regionInstanceGroups | Supported |
| [Regionoperations](https://cloud.google.com/compute/docs/reference/latest/regionOperations) | gce.regionOperations | Supported |
| [Regions](https://cloud.google.com/compute/docs/reference/latest/regions) | gce.regions | Untested |
| [Routers](https://cloud.google.com/compute/docs/reference/latest/routers) | gce.routers | Untested |
| [Routes](https://cloud.google.com/compute/docs/reference/latest/routes) | gce.routes | Untested |
| [Snapshots](https://cloud.google.com/compute/docs/reference/latest/snapshots) | gce.snapshots | Untested |
| [Sslcertificates](https://cloud.google.com/compute/docs/reference/latest/sslCertificates) | gce.sslCertificates | Untested |
| [Subnetworks](https://cloud.google.com/compute/docs/reference/latest/subnetworks) | gce.subnetworks | Supported |
| [Targethttpproxies](https://cloud.google.com/compute/docs/reference/latest/targetHttpProxies) | gce.targetHttpProxies | Supported |
| [Targethttpsproxies](https://cloud.google.com/compute/docs/reference/latest/targetHttpsProxies) | gce.targetHttpsProxies | Untested |
| [Targetinstances](https://cloud.google.com/compute/docs/reference/latest/targetInstances) | gce.targetInstances | Untested |
| [Targetpools](https://cloud.google.com/compute/docs/reference/latest/targetPools) | gce.targetPools | Supported |
| [Targetsslproxies](https://cloud.google.com/compute/docs/reference/latest/targetSslProxies) | gce.targetSslProxies | Untested |
| [Targetvpngateways](https://cloud.google.com/compute/docs/reference/latest/targetVpnGateways) | gce.targetVpnGateways | Untested |
| [Urlmaps](https://cloud.google.com/compute/docs/reference/latest/urlMaps) | gce.urlMaps | Untested |
| [Vpntunnels](https://cloud.google.com/compute/docs/reference/latest/vpnTunnels) | gce.vpnTunnels | Untested |
| [Zoneoperations](https://cloud.google.com/compute/docs/reference/latest/zoneOperations) | gce.zoneOperations | Supported |
| [Zones](https://cloud.google.com/compute/docs/reference/latest/zones) | gce.zones | Untested |

## Examples
- [GCE External Network LoadBalancer](examples/gce_external_network_lb/README.md)
	
## Known Issues / Limitations
- List and AggregatedList actions cause an error when no results are returned.
- Delete/Provision produce a 404 error if the operation returns an error.
- actions which return a JSON response that isn't a resource is untested.
- Outputs support only top level JSON nodes so return responses with JSON subnodes have been removed with the top level node containing the full JSON. (Untested)

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GCE Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.
