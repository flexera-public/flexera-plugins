# VMware NSX Plugin

## Overview
The VMWare NSX Plugin integrates RightScale Self-Service with the VMWare NSX addon for vSphere.

## Requirements
- NSX Manager
  - Refer to the NSX Documentation for installation and Configuration details.
- WSTunnel
  - https://github.com/rightscale/wstunnel
  - http://docs.rightscale.com/faq/wstunnel_setup.html
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- The following RightScale Credentials
  - `NSX_USER`
  - `NSX_PASSWORD`
- J2XRP
This is a JSON to XML payload conversion service. It's required to workaround a limitation in Self-Service Plugins which doesn't support sending an XML body which NSX expects.
  - https://github.com/flaccid/j2xrp
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect VMware Cloud credentials to your RightScale account (optional)
1. Setup NSX Manager on a instance with outbound internet access. Refer to the NSX manual for details on how to do this.
1. Follow steps to [Setup WSTunnel](http://docs.rightscale.com/faq/wstunnel_setup.html)
  1. Be sure to put the instance on a network which can reach the NSX Manager.
  1. REGEXP should be the 'https://<nsx manager ip>'
  1. SERVER should be the 'https://<nsx manager ip>:<port>'
1. Create the required RightScale credentials.
1. Create RightScale Credentials with values that match the NSX User (Credential name: `NSX_USER`) & NSX Password (Credential name: `NSX_PASSWORD`) that will be used by Self-Service to interact with NSX. This user must have permissions required by the CloudApplication. 
1. Update the default_host and path of the nsx_plugin.cat.rb to include the host where j2xrp resides and the _token value generated in the wstunnel setup.
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `nsx_plugin.cat.rb` file located in this repository
 
## How to Use
The VMWare NSX Plugin has been packaged as `plugins/nsx`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/nsx"
```
For more information on using packages, please refer to the RightScale online documentation. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

VMWare NSX resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources

 - 
 - firewall_layer3rule (rules)
 - application

## Usage
See the [examples](./examples) directory within this repo to see specific examples for various resource types. 
```
permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

parameter 'stack_name' do
  label 'Name'
  description 'The name of the stack. Will prepend to resources.'
  category 'NSX FW Demo'
  type 'string'
  min_length 2
  default "fw-demo"
end

resource 'stack_security_tag', type: 'nsx.security_tag' do
  # Tag to be applied to web1 dynamically associates it with web1_security_group
  name join([$stack_name,"-","stack-st"])
  description join(["stack_secuirty_tag for ",$stack_name,"."])
end

resource 'stack_security_group', type: 'nsx.security_group' do
  # Security Group composed of web1_security_tag instances used in firewall rules
  name join([$stack_name,"-","stack-sg"])
  description join(["stack_secuirty_group for ",$stack_name,"."])
  dynamicMemberDefinition do {
'dynamicSet' => {
'operator' => 'OR',
'dynamicCriteria' => {
  'operator' => 'OR',
  'key' => 'ENTITY',
  'criteria' => 'belongs_to',
  'value' => @stack_security_tag.objectId
}
}
  }end
end
```
## Resources
### security_group
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|Name of the resource.|
|description|No|Description for the resource.|
|scope|Yes|For the scopeId use globalroot-0 for non-universal security groups and universalroot-0 for universal security groups.|
|isUniversal|Yes|Set to true when creating a univeral Security Group.|
|inheritanceAllowed|No|Set to true to allow inheritance.|

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
|create| [Working With Security Group Grouping Objects pg.85](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|delete| [Working With Security Group Grouping Objects pg.85](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|list| [Working With Security Group Grouping Objects pg.85](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|get| [Working With Security Group Grouping Objects pg.85](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|

#### Supported Outputs
- objectId
- objectTypeName
- revision
- description
- name

### security_tag 
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|Name of the resource.|
|description|No|Description for the resource.|

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
|create|[Working With Security Tags pg.73](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|list|[Working With Security Tags pg.73](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|delete|[Working With Security Tags pg.73](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|get|[Working With Security Tags pg.73](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|add_vm|[Working With Security Tags pg.73](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|rm_vm|[Working With Security Tags pg.73](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
#### Supported Outputs
- objectId
- objectTypeName
- name
- description
- type
- extendedAttributes
### firewall
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
|get|[Working With Security Tags pg.197](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|create_layer2section|[Working With Security Tags pg.197](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|See known issues|
|create_layer3section|[Working With Security Tags pg.197](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|See known issues|
#### Supported Outputs
- firewallConfiguration
- ETag

### firewall_layer3section
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|section|Yes|Object defining a section.|

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
|create|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|delete|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|update|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|show|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|list|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|add_firewall_rule|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|list_firewall_rules|[Working With Layer 3 Sections in Distributed Firewall pg.201](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
#### Supported Outputs
- objectId
- ETag

### firewall_layer3rules
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|rule|Yes|Object defining a rule.|
|sectionId|Yes|sectionId to add rule to.|
|section_etag|Yes|Current ETag of the section being modified|

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
|create|[Working With Distributed Firewall Rules in a Layer 3 Section pg.210](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|delete|[Working With Distributed Firewall Rules in a Layer 3 Section pg.210](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|update|[Working With Distributed Firewall Rules in a Layer 3 Section pg.210](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|get|[Working With Distributed Firewall Rules in a Layer 3 Section pg.210](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|

#### Supported Outputs
- objectId
- ETag

### application
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|Name of the resource.|
|element|Yes|Object describing the element.|
|description|No|Description of the resource.|
|revision|No|Application Revision|
#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
|create|[Working With Services Grouping Objects pg.61](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|delete|[Working With Services Grouping Objects pg.61](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|update|[Working With Services Grouping Objects pg.61](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|get|[Working With Services Grouping Objects pg.61](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
|list|[Working With Services Grouping Objects pg.61](https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf)|Supported|
#### Supported Outputs
- element
- objectId
- description
- name
- revision

## Implementation Notes
- Firewall manipulation with this plugin happens at a global level. Make sure your rules are setup disallow all unwanted traffic (default deny) prior to using this plugin to avoid undesirable behavior.
- It recommended to group CloudApp firewall rules grouped using firewall layer sections.
 
## Examples
See [Examples](./examples).
	
## Known Issues / Limitations
- The NSX API doesn't provide enough information for Self-Service to identify a Rule as a resource. They can be created using a resource block but will not be listed as a resource nor can they be manipulated after creation. Deletion of the firewall section will remove the rule on termination if you are folloing the implementation notes.
- Layer2Sections has not been fully implemented due to a limitation in NSX API which doesn't allow Self-Service to distinguish between a layer2 and a layer3 resource. It's possible to use either, but not both at the same time. A future update will correct this limitation.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel `#plugins`.
Visit http://chat.rightscale.com/ to join!

## License
The VMWare NSX Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.