# AWS VPC Plugin

## Overview
The AWS VPC Plugin integrates RightScale Self-Service with the basic functionality of the AWS VPC. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- Admin rights to a RightScale account with SelfService enabled
  - Admin is needed to set/retrieve the RightScale Credentials for the VPC API.
- AWS Account credentials with the appropriate permissions to manage elastic load balancers
- The following RightScale Credentials
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Installation
1. Be sure your RightScale account is SelfService enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate SelfService portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_vpc_plugin.rb` file located in this repository
 
## How to Use
The VPC Plugin has been packaged as `plugin/rs_aws_vpc`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_vpc"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

AWS VPC resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
## Supported Resources
 - vpc
 - endpoint
 - route_table
 - nat_gateway
 - addresses
 - tags

## Usage
```
#Creates an VPC
resource "my_vpc", type: "rs_aws_vpc.vpc" do
  cidr_block "10.0.0.0/16"
  instance_tenancy "default"
end

resource "my_vpc_endpoint", type: "rs_aws_vpc.endpoint" do
  vpc_id @my_vpc.vpcId
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_rs_vpc", type: "rs_cm.network" do
  name "my_rs_vpc"
  cidr_block "10.0.0.0/16"
  cloud_href "/api/clouds/1"
end

resource "my_rs_vpc_endpoint", type: "rs_aws_vpc.endpoint" do
  vpc_id @my_rs_vpc.resource_uid
  service_name "com.amazonaws.us-east-1.s3"
end
```
#
## Resources
## vpc
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|amazon_provided_ipv6_cidr_block|No|Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block.|
|cidr_block|Yes|The IPv4 network range for the VPC, in CIDR notation. For example, 10.0.0.0/16.|
|instance_tenancy|No|The tenancy options for instances launched into the VPC. For default, instances are launched with shared tenancy by default. You can launch instances with any tenancy into a shared tenancy VPC. For dedicated, instances are launched as dedicated tenancy instances by default. You can only launch instances with a tenancy of dedicated or host into a dedicated tenancy VPC.|

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateVpc](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateVpc.html) | Supported |
| destroy | [DeleteVpc](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteVpc.html) | Supported |
| list,get, show | [DescribeVpcs](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeVpcs.html) | Supported |
| routeTables | [DescribeRouteTables](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeRouteTables.html) | Supported |
| enablevpcclassiclink | [EnableVpcClassicLink](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_EnableVpcClassicLink.html) | Supported |
| disablevpcclassiclink | [DisableVpcClassicLink](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DisableVpcClassicLink.html) | Untested |
| enablevpcclassiclinkdnssupport | [EnableVpcClassicLinkDnsSupport](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_EnableVpcClassicLinkDnsSupport.html) | Supported |
| disablevpcclassiclinkdnssupport | [DisableVpcClassicLinkDnsSupport](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DisableVpcClassicLinkDnsSupport.html) | Untested |
| create_tag | [CreateTags](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateTags.html) | Supported |
| delete_tag | [DeleteTags](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteTags.html) | Untested |
*Note*:  routeTables behaves more like a link then action

## endpoint
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|vpc_id| Yes | The ID of the VPC in which the endpoint will be used. |
|service_name| Yes | The AWS service name, in the form com.amazonaws.region.service . |
|route_table_id_1| No | Route Table to pin to |
|vpc_interface_type| No | The type of endpoint. Options: Interface/Gateway, Default: Gateway |
|private_dns_enabled| No| (Interface endpoint) Indicate whether to associate a private hosted zone with the specified VPC. Default: True |
|security_group_id_1| No | (Interface endpoint) The ID of one or more security groups to associate with the endpoint network interface. |

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateVpcEndpoint](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateVpcEndpoint.html) | Supported |
| destroy | [DeleteVpcEndpoints](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteVpcEndpoints.html) | Supported |
| list | [DescribeVpcEndpoints](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeVpcEndpoints.html) | Supported |

## route_table
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|vpc_id| Yes | The ID of the VPC in which the endpoint will be used. |

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateRouteTable](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateRouteTable.html) | Supported |
| destroy | [DeleteRouteTable](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteRouteTable.html) | Supported |
| list | [DescribeRouteTables](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeRouteTables.html) | Supported |

## nat_gateway
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|allocation_id| Yes | The allocation ID of an Elastic IP address to associate with the NAT gateway. If the Elastic IP address is associated with another resource, you must first disassociate it. |
|subnet_id| Yes | The subnet in which to create the NAT gateway.|

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateNatGateway](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateNatGateway.html) | Supported |
| destroy | [DeleteNatGateway](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteNatGateway.html) | Supported |
| list | [DescribeNatGateways](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeNatGateways.html) | Supported |

## addresses
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|allocation_id_1| No | One or more allocation IDs. |
|public_ip_1| No | One or more Elastic IP addresses|

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| show | [DescribeAddresses](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeAddresses.html) | Supported |

## tags
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|resource_id_1| Yes | The IDs of one or more resources to tag. |
|tag_1_key| Yes | Tag Key |
|tag_1_value | Yes | Tag Value |

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateTags](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateTags.html) | Supported |
| destroy | [DeleteTags](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteTags.html) | Supported |

# Implementation Notes
- The AWS VPC Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an VPC resource.) 
 - The most common example might be to pass a RightScale instance to attach it to the VPC or similar. Support for this functionality will need to be implemented in the application CAT.
 
Full list of possible actions can be found on the [AWS VPC API Documentation](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/Welcome.html)
## Examples
Please review [vpc_plugin_test_cat.rb](./vpc_plugin_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS VPC Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
