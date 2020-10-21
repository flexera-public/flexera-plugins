# Fastly ipaddresslist

## Overview

The Fastly ipaddresslist plugin integrates RightScale Self-Service with the basic functionality of the Fastly Public Ip LIst.

## Requirements

- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrieved the RightScale Credential values identified below.
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started

### Installation

1. Modify the plugin file itself and insert your wstunnel token in the resource_pool section.
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `fastly_ipaddress_plugin.rb` file located in this repository

### How to Use

The  Plugin has been packaged as `plugins/rs_rs_fastly_ipaddress`. To use this plugin you must import this plugin into a CAT.

```ruby

import "sys_log"
import "plugins/rs_fastly_ipaddress"

```

For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources

- public_ip_list

## Resource: `public_ip_list`

### Usage

```ruby

output "addresses" do
  label "Host IPv4 Address"
  category "Outputs"
  default_value $address_list
end

operation "launch" do
  label "Launch"
  definition "gen_launch"
  output_mappings do {
      $addresses => $address_list
  } end
end

define gen_launch() return @fastly,$address_list do
  @fastly = rs_fastly_ipaddress.public_ip_list.show()
  $address_list = to_s(@fastly.addresses)
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| show | <https://api.fastly.com/public-ip-list> | supported |

#### Supported Outputs

- "addresses" - list of fastly public ips

#### Supported Links

NONE

## Examples

See [test_fastly_ipaddress.cat.rb](./test_fastly_ipaddress.cat.cat.rb) for an example declaration.

## Known Issues / Limitations

## License

The source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
