# AWS EFS Plugin

## Overview
The AWS EFS Plugin integrates RightScale Self-Service with the basic functionality of the AWS Elastic File System API. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- AWS Account credentials with the appropriate permissions to manage elastic load balancers
- The following RightScale Credentials
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started
**Coming Soon**

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_efs_plugin.rb` file located in this repository
 
## How to Use
The EFS Plugin has been packaged as `plugin/rs_aws_efs`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_efs"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
### file_systems

#### Supported Fields
**Note:** There are many possible configurations when defining a `file_systems` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed API documentation is available [here](http://docs.aws.amazon.com/efs/latest/ug/api-reference.html).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| creation_token | yes | Amazon EFS uses to ensure idempotent creation (calling the operation with same creation token has no effect) | 
| performance_mode | no | The PerformanceMode of the file system. AWS recommends `generalPurpose` performance mode for most file systems. File systems using the `maxIO` performance mode can scale to higher levels of aggregate throughput and operations per second with a tradeoff of slightly higher latencies for most file operations. This can't be changed after the file system has been created. | 
| tags | no | Key/Value array of tags.  Note that if you would like to name your file_systems resource, you must pass a value for a tag Key named "Name" | 

#### Supported Outputs
- OwnerId
- CreationToken
- PerformanceMode
- FileSystemId
- CreationTime
- LifeCycleState
- NumberOfMountTargets

#### Usage
AWS EFS resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new EFS File System
resource "my_efs", type: "rs_aws_efs.file_systems" do
  creation_token join(["efs-", last(split(@@deployment.href, "/"))])
  performance_mode "generalPurpose"
  tags do {
    "Key" => "Name",
    "Value" => "MyEFS"
  } end
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateFileSystem](http://docs.aws.amazon.com/efs/latest/ug/API_CreateFileSystem.html) | Supported |
| destroy | [DeleteFileSystem](http://docs.aws.amazon.com/efs/latest/ug/API_DeleteFileSystem.html) | Supported |
| list & get | [DescribeFileSystems](http://docs.aws.amazon.com/efs/latest/ug/API_DescribeFileSystems.html) | Supported |
| apply_tags | [CreateTags](http://docs.aws.amazon.com/efs/latest/ug/API_CreateTags.html) | Supported |
| delete_tags | [DeleteTags](http://docs.aws.amazon.com/efs/latest/ug/API_DeleteTags.html) | Supported |
| get_tags | [DescribeTags](http://docs.aws.amazon.com/efs/latest/ug/API_DeleteTags.html) | Supported |

### mount_targets

#### Supported Fields
**Note:** There are many possible configurations when defining a `mount_targets` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed API documentation is available [here](http://docs.aws.amazon.com/efs/latest/ug/api-reference.html).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| file_system_id | yes | FileSystemId of the EFS File System in which the Mount Target will be created |  
| ip_address | no | If specified, Amazon EFS assigns that IP address to the network interface. Otherwise, Amazon EFS assigns a free address in the subnet | 
| security_groups | no | If specified, the network interface is associated with the identified security groups. Otherwise, it belongs to the default security group for the subnet's VPC | 
| subnet_id | yes | ID of the subnet to add the mount target in.  ie. `subnet-12345678` |

#### Supported Outputs
- IpAddress
- MountTargetId
- NetworkInterfaceId 
- SubnetId
- OwnerId
- FileSystemId
- LifeCycleState

#### Supported Links
| Link | Associated Resource |
|------|---------------------|
| file_systems() | file_systems | 

#### Usage
AWS EFS resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new EFS Mount Target
resource "my_mount", type: "rs_aws_efs.mount_targets" do
  file_system_id @my_efs.FileSystemId
  subnet_id "subnet-1234abcd"
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateMountTarget](http://docs.aws.amazon.com/efs/latest/ug/API_CreateMountTarget.html) | Supported |
| destroy | [DeleteMountTarget](http://docs.aws.amazon.com/efs/latest/ug/API_DeleteMountTarget.html) | Supported |
| list & get | [DescribeMountTargets](http://docs.aws.amazon.com/efs/latest/ug/API_DescribeMountTargets.html) | Supported |


## Examples
Please review [efs_test_cat.rb](./efs_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "efs" do
  plugin $rs_aws_efs
  host "elasticfilesystem.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'elasticfilesystem'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end
```

## TODO
- Add support for:
  - [DescribeMountTargetSecurityGroups](http://docs.aws.amazon.com/efs/latest/ug/API_DescribeMountTargetSecurityGroups.html)
  - [ModifyMountTargetSecurityGroups](http://docs.aws.amazon.com/efs/latest/ug/API_ModifyMountTargetSecurityGroups.html)

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS EFS Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.




