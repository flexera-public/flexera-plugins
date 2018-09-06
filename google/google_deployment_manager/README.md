# Google Cloud Deployment Plugin

## Overview
The Google Cloud Deployment plugin consumes the Google Deployment Manager API and exposes the supported resources to RightScale Self-Service. This allows for easy extension of a Self-Service Cloud Application to create, delete, and manage Google Deployment Managers.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- `admin`, `ss_enduser`, & `ss_designer` roles on a RightScale account with Self-Service enabled
  - the `admin` role is needed to set/retrieve the RightScale Credentials for the Google Deployment Manager API.
- GDM Service Account credentials
  - Refer to the Getting Started section for details on creating this account.
- The following RightScale Credentials must exist with the appropriate values
  - `GCE_PLUGIN_ACCOUNT`
  - `GCE_PLUGIN_PRIVATE_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)
- Enable the Google Deployment Manager API on your Project. Refer to [Google Documentation](https://console.developers.google.com/apis/library/deploymentmanager.googleapis.com) for more information.

## Getting Started
### Creating a GDM Service Account
This procedure will create a GCE Service account with the appropriate permissions to use this plugin.
1. Review the [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) documentation.
1. Follow the section named _Creating a service account_
    - Roles needs to include:
      - `Deployment Manager Editor`
      - `Deployment Manager Type Editor`
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
1. Be sure your RightScale account has Self-Service enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `gce_dm_plugin.rb` file located in this repository
 
## How to Use
The Google Deployment Manager has been packaged as `plugins/GDM_dm`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/GDM_dm"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
### deployments
#### Supported Fields

See Google documentation [here](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments)

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | 	Name of the resource; provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash.| 
| target | yes | [Input Only] The parameters that define your deployment, including the deployment configuration and relevant templates.|
| labels | no | Map of labels; provided by the client when the resource is created or updated. Specifically: Label keys must be between 1 and 63 characters long and must conform to the following regular expression: [a-z]([-a-z0-9]*[a-z0-9])? Label values must be between 0 and 63 characters long and must conform to the regular expression ([a-z]([-a-z0-9]*[a-z0-9])?)?  | 

#### Supported Outputs
- kind
- id
- creationTimestamp
- name
- zone
- clientOperationId
- operationType
- targetLink
- targetId
- status
- statusMessage
- user
- progress
- insertTime
- startTime
- endTime
- error
- warnings
- httpErrorStatusCode
- httpErrorMessage
- selfLink
- region
- description

#### Usage
A Google Deployment can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new Google Deployment
resource "GDM_dm_deployment", type: "GDM_dm.deployment" do
  name join(["beyondtrust-",last(split(@@deployment.href, "/"))])
  target do {
    "config" => {
      "content" => '{
        "imports": [
          {
            "path": "beyondtrust.jinja"
          }
        ],
        "resources": [
          {
            "name": "beyondtrust",
            "type": "beyondtrust.jinja",
            "properties": {
              "zone": "us-central1-a",
              "machineType": "n1-standard-8",
              "bootDiskType": "pd-standard",
              "bootDiskSizeGb": 100,
              "network": "default",
              "subnetwork": "default",
              "externalIP": "Ephemeral",
              "tcp443SourceRanges": "",
              "enableTcp443": true,
              "ipForward": "On"
            }
          }
        ]
      }'
    },
    "imports" =>  [
    ]
  } end
  labels do [
    { "key": "cloud-marketplace", "value":"beyondtrust-production-beyondtrust" },
    { "key": "cloud-marketplace-partner-id", "value":"beyondtrust-production" },
    { "key": "cloud-marketplace-solution-id", "value":"beyondtrust" }
  ] end
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| insert | [insert](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/insert) | Supported |
| delete | [delete](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/delete) | Supported |
| get | [get](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/get) | Supported |
| list | [list](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/list) | Supported |
| cancelPreview | [cancelPreview](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/cancelPreview) | Untested |
| patch | [patch](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/patch) | Untested |
| stop | [stop](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/stop)| Untested |
| update | [update](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/update) | Untested |
| show | [show](https://cloud.google.com/deployment-manager/docs/reference/latest/deployments/get) | Untested |

## Examples
- [gce_dm_test_cat.rb](./gce_dm_test_cat.rb)
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GDM Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
