# Digital Ocean Plugin

## Overview
The Digital Ocean Plugin integrates RightScale Self-Service with the basic functionality of the Digital Ocean API.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- The following RightScale Credentials
  - `DIGITAL_OCEAN_API_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)
  - [plugin_generics](../../libraries/plugin_generics.rb)

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Generate a Digital Ocean [API Key](https://cloud.digitalocean.com/settings/applications)
1. Create a RightScale Credential named `DIGITAL_OCEAN_API_KEY` with the value of the API Key generated in the previous step
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `rs_do_plugin.rb` file located in this repository

## How to Use
The Digital Ocean Plugin has been packaged as `plugins/rs_do`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_do"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- droplet

## Usage
```
resource "my_droplet", type: "rs_do.droplet" do
  name join(["rightscale-",last(split(@@deployment.href, "/"))])
  region "nyc1"
  size "s-1vcpu-1gb"
  image "docker"
end
```
## Resources
### droplet
#### Supported Fields
| Field Name | Required? |
|------------|-----------|
| name | yes |
| region | yes |
| size | yes |
| image | yes |
| ssh_keys | no |
| backups | no |
| ipv6 | no |
| private_networking | no |
| user_data | no |
| monitoring | no |
| volumes | no |
| tags | no |

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get | [Retrieve an existing Droplet by ID](https://developers.digitalocean.com/documentation/v2/#retrieve-an-existing-droplet-by-id) | supported |
| list | [List all Droplets](https://developers.digitalocean.com/documentation/v2/#list-all-droplets) | supported |
| show | [Retrieve an existing Droplet by ID](https://developers.digitalocean.com/documentation/v2/#retrieve-an-existing-droplet-by-id) | supported |
| create | [Create a new Droplet](https://developers.digitalocean.com/documentation/v2/#create-a-new-droplet) | supported |
| destroy | [Delete a Droplet](https://developers.digitalocean.com/documentation/v2/#delete-a-droplet) | supported |

#### Outputs
- id
- name
- memory
- vcpus
- disk
- locked
- created_at
- status
- features
- region
- image
- size
- size_slug
- networks
- kernel
- next_backup_window
- backup_ids
- snapshot_ids
- volume_ids
- tags

## Implementation Notes
- The Digital Ocean Plugin makes no attempt to support non-Digital Ocean resources. (i.e. Allow the passing the RightScale or other resources as arguments to an Digital Ocean resource.)

## Examples
Please review [digital_ocean_test_cat.rb](./digital_ocean_test_cat.rb) for a basic example implementation.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Digital Ocean Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
