# AWS Compute Plugin

## Overview
The AWS Compute Plugin integrates RightScale Self-Service with the basic functionality of the AWS Compute. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- Admin rights to a RightScale account with SelfService enabled
  - Admin is needed to set/retrieve the RightScale Credentials for the Compute API.
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
   1. Upload the `aws_compute_plugin.rb` file located in this repository
 
## How to Use
The Compute Plugin has been packaged as `plugin/rs_aws_compute`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_compute"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

AWS Compute resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
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
resource "my_vpc", type: "rs_aws_compute.vpc" do
  cidr_block "10.0.0.0/16"
  instance_tenancy "default"
end

resource "my_vpc_endpoint", type: "rs_aws_compute.endpoint" do
  vpc_id @my_vpc.vpcId
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_rs_vpc", type: "rs_cm.network" do
  name "my_rs_vpc"
  cidr_block "10.0.0.0/16"
  cloud_href "/api/clouds/1"
end

resource "my_rs_vpc_endpoint", type: "rs_aws_compute.endpoint" do
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

## volume
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| availability_zone | Yes | The Availability Zone in which to create the volume. Use DescribeAvailabilityZones to list the Availability Zones that are currently available to you. |
| encrypted | No | Specifies whether the volume should be encrypted. Encrypted Amazon EBS volumes may only be attached to instances that support Amazon EBS encryption. Volumes that are created from encrypted snapshots are automatically encrypted. There is no way to create an encrypted volume from an unencrypted snapshot or vice versa. If your AMI uses encrypted volumes, you can only launch it on supported instance types. For more information, see Amazon EBS Encryption in the Amazon Elastic Compute Cloud User Guide.  |
| iops | No | The number of I/O operations per second (IOPS) to provision for the volume, with a maximum ratio of 50 IOPS/GiB. Range is 100 to 32000 IOPS for volumes in most regions. For exceptions, see Amazon EBS Volume Types in the Amazon Elastic Compute Cloud User Guide.  |
| kms_key_id | No | An identifier for the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. This parameter is only required if you want to use a non-default CMK; if this parameter is not specified, the default CMK for EBS is used. If a KmsKeyId is specified, the Encrypted flag must also be set.  |
| size | No | The size of the volume, in GiBs. |
| snapshot_id | No | The snapshot from which to create the volume. |
| volume_type | No | The volume type. This can be gp2 for General Purpose SSD, io1 for Provisioned IOPS SSD, st1 for Throughput Optimized HDD, sc1 for Cold HDD, or standard for Magnetic volumes.  |

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateVolume](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateVolume.html) | Supported |
| destroy | [DeleteVolume](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteVolume.html) | Supported |
| get | [DescribeVolumes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeVolumes.html) | Supported |

## volume_modification
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| volume_id | yes | The ID of the volume. |
| iops | No | The number of I/O operations per second (IOPS) to provision for the volume, with a maximum ratio of 50 IOPS/GiB. Range is 100 to 32000 IOPS for volumes in most regions. For exceptions, see Amazon EBS Volume Types in the Amazon Elastic Compute Cloud User Guide.  |
| size | No | The size of the volume, in GiBs. |
| volume_type | No | The volume type. This can be gp2 for General Purpose SSD, io1 for Provisioned IOPS SSD, st1 for Throughput Optimized HDD, sc1 for Cold HDD, or standard for Magnetic volumes.  |

## Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [ModifyVolume](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyVolume.html) | Supported |
| get | [DescribeVolumesModifications](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeVolumesModifications.html) | Supported |

# Implementation Notes
- The AWS Compute Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an VPC resource.) 
 - The most common example might be to pass a RightScale instance to attach it to the VPC or similar. Support for this functionality will need to be implemented in the application CAT.
 
Full list of possible actions can be found on the [AWS Compute API Documentation](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/Welcome.html)
## Examples
Please review [compute_plugin_test_cat.rb](./compute_plugin_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS Compute Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
