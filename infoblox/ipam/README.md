# Infoblox IPAM Plugin

## Overview
The Infoblox IPAM plugin integrates RightScale Self-Service with the basic functionality of the Infoblox IPAM API. 

## TO-DOs
- Once supported, use cred() for the tunnel token parameter.
- Support additional Infoblox IPAM objects beyond the "record:host" object

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- Infoblox service account credentials with the appropriate permissions to manage IPAM entries.
  - The Infoblox service account MUST be enabled for API access. There is a user account setting in Infoblox to enable this.
  - The Infoblox service account must have write permissions to the zone(s) being used for the host name.
  - The Infoblox service account must have CRUD permissions to the network (i.e. CIDR) from which IP addresses are being assigned.
- Since Infoblox is an on premise solution, the plugin assumes a wstunnel is being used.
  - Refer to the wstunnel documentation for details [WStunnel Guide](http://docs.rightscale.com/faq/wstunnel_setup.html)
- The following RightScale Credentials
  - `INFOBLOX_USERID` - The Infoblox service account username.
  - `INFOBLOX_PASSWORD` - The Infoblox service account password.
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Getting Started

### Installation
1. Modify the plugin file itself and insert your wstunnel token in the resource_pool section.
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `infoblox_ipam.plugin.rb` file located in this repository
 
### How to Use
The  Plugin has been packaged as `plugins/rs_infoblox_ipam`. To use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_infoblox_ipam"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- record:host

## Resource: `record:host`

#### Usage
```
parameter "param_hostname" do
    label "Host Name"
    type "string"
end

parameter "param_domain" do
    label "Host Domain"
    type "string"
end

parameter "param_cidrblock" do
  label "Network CIDR to Use"
  type "string"
end

# Creates a host record with the next available IP address.
resource "hostrecord", type: "rs_infoblox_ipam.record_host" do
    name join([$param_hostname,".",$param_domain])
    ipv4addrs [{ ipv4addr:join(["func:nextavailableip:",$param_cidrblock]) }]
end
```

#### Supported Fields

| Field Name | Required? | Field Type | Default Value | Description |
|------------|-----------|------------|---------------|-------------|
| name | yes | string | empty | The host FQDN to which the IP is being assigned. Must contain the zone name (e.g. example.com) that the infoblox service account supports.  |
| ipv4addrs | no(yes) | array of hashes | empty | Must declare an ipv4addrs or an ipv6addrs. This field is an array of hashes declaring the address to use. This string can be used to get the next available IP: [{ "ipv4addr":"func:nextavailableip:10.1.124.0/24" }]. To get a specific IP use this: [{ "ipv4addr":"10.1.124.53" }] |
| ipv6addrs | no | array of hashes | empty | Must declare at least an ipv4addrs or an ipv6addrs. This field is constructed the same as ipv4addrs but with "ipv6addrs" in it. |
| aliases | no | array of strings | empty | This is a list of aliases for the host. The aliases must be in FQDN format. This value can be in unicode format. |
| allow_telnet | no | boolean | false | This field controls whether the credential is used for both the Telnet and SSH credentials. If set to False, the credential is used only for SSH. 
| comment | no | string | empty | Comment for the record; maximum 256 characters. |
| configure_for_dns | no | boolean | true | When configure_for_dns is false, the host does not have parent zone information. |
| device_description | no | string | empty | The description of the device.
| device_location | no | string | empty | The location of the device. |
| device_type | no | string | empty | The type of the device. |
| device_vendor | no | string | empty | The vendor of the device. |
| disable | no | boolean | false | Determines if the record is disabled or not. False means that the record is enabled. |
| disable_discovery | no | false | Determines if the discovery for the record is disabled or not. False means that the discovery is enabled. |
| dns_aliases | no | array of strings | empty | The list of aliases for the host in punycode format. The name is a default dns name. |
| use_ttl | no | boolean | false | Use flag for ttl parameter. If not used, default ttl is used for records. |
| ttl | no | number | empty | The Time To Live (TTL) value for record. A 32-bit unsigned integer that represents the duration, in seconds, for which the record is valid (cached). Zero indicates that the record should not be cached. |

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | https://ipam.illinois.edu/wapidoc/objects/record.host.html | supported |
| destroy | https://ipam.illinois.edu/wapidoc/objects/record.host.html | supported |
| show | https://ipam.illinois.edu/wapidoc/objects/record.host.html | supported |
| list_by_name | https://ipam.illinois.edu/wapidoc/objects/record.host.html#name | supported |
| search | https://ipam.illinois.edu/wapidoc/objects/record.host.html#fields-list | supported |

#### Supported Outputs
- "_ref" - Infoblox host:record reference
- "name" - host name
- "ipv4addr" - host IPv4 address (if configured)
- "ipv6addr" - host IPv6 address (if configured)

#### Supported Links
NONE

## Examples
See [test_infoblox_ipam.cat.rb](./test_infoblox_ipam.cat.rb) for an example decalaration and use of the list_by_name and search actions.

## Known Issues / Limitations
- The outputs only support single IP address assignments. 
- Some of the more esoteric inputs supported by the API are not supported by the plugin. For example the credentials-oriented fields such as "cli_credentials" are not supported. 

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Infoblox IPAM Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
