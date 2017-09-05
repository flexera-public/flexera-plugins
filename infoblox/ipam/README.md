# Infoblox IPAM Plugin

## Overview
The Infoblox IPAM plugin integrates RightScale Self-Service with the basic functionality of the Infoblox IPAM API. 

## TO-DOs
- Make tunnel token a field so it can be passed as a cred.
- Support bulk provisioning.
- Add inputs to specify name and zone and then construct the name passed to infoblox instead of requiring user to provide entire name.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- Infoblox Account credentials with the appropriate permissions to manage IPAM entries.
  - NOTE: the Infoblox user account MUST be enabled for API access. There is a user account setting in Infoblox to enable this.
- Since Infoblox is an on premise solution, the plugin assumes a wstunnel is being used.
  - Refer to the wstunnel documentation for details [WStunnel Guide](http://docs.rightscale.com/faq/wstunnel_setup.html)
- The following RightScale Credentials
  - `INFOBLOX_USERID`
  - `INFOBLOX_PASSWORD`
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Getting Started

### Installation
1. Be sure your RightScale account has Self-Service enabled
1. Modify the plugin file itself and insert your wstunnel token in the resource_pool section.
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `infoblox_ipam.plugin.rb` file located in this repository
 
### How to Use
The  Plugin has been packaged as `plugins/rs_infoblox_ipam`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_infoblox_ipam"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- record:host

## Resource: `record:host`

#### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | The host FQDN to which the IP is being assigned. Must contain the zone name (e.g. example.com) that the infoblox service account supports.  |
|ut_in_minutes | no | The amount of time that can pass before the stack status becomes CREATE_FAILED; if `disable_rollback` is not set or is set to false, the stack will be rolled back. Note: the auto-provision definition of `stack` resources includes a 1 hour timeout.  If you need to extend that timeout, it is recommended to either edit the provision defintion in the plugin OR use a custom provision definition in your CAT. |



#### Usage
TBD
```
resource ....
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | | |
| destroy | | |
| get | | |
#### Supported Links

NONE

## Resource: `resources`

TBD

#### Supported Fields
TBD

#### Supported Outputs
TBD

#### Supported Links
TBD

#### Supported Actions

TBD

## Examples
TBD
	
## Known Issues / Limitations
TBD

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Infoblox IPAM Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
