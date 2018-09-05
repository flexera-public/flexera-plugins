# AWS IAM Plugin

## Overview
The AWS IAM Plugin integrates RightScale Self-Service with the basic functionality of the AWS Identify and Access Management API.

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
  - [plugin_generics](../../libraries/plugin_generics.rb)


## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_iam_plugin.rb` file located in this repository

## How to Use
The IAM Plugin has been packaged as `plugin/rs_aws_iam`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_iam"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
 - role
 - policy
 - instance_profile

## Resource: `role`

#### Supported Fields
**Note:** There are many possible configurations when defining a `role` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed field documentation is available in-line within the IAM Plugin.

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes | The name of the role to create. |
| assume_role_policy_document | yes |  The trust relationship policy document that grants an entity permission to assume the role. |
| description | no | A description of the role. |
| availability_zone | no | The EC2 Availability Zone that the database instance will be created in. |
| max_session_duration | no | The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. |
| path | no | The path to the role. |
| policies | no | Attaches the specified managed policy to the specified IAM role. When you attach a managed policy to a role, the managed policy becomes part of the role's permission (access) policy. |

#### Supported Outputs
- RoleName

#### Usage
AWS IAM resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
resource "my_role", type: "rs_aws_iam.role" do
  name 'MyTestRole'
  assume_role_policy_document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["ec2.amazonaws.com"]},"Action":["sts:AssumeRole"]}]}'
  description "test role description"
  policies @my_policy.Arn, @my_policy2.Arn
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateRole](https://docs.aws.amazon.com/IAM/latest/APIReference/API_CreateRole.html) | Supported |
| destroy | [DeleteRole](https://docs.aws.amazon.com/IAM/latest/APIReference/API_DeleteRole.html) | Supported |
| get | [GetRole](https://docs.aws.amazon.com/IAM/latest/APIReference/API_GetRole.html) | Supported |
| attach_policy | [AttachRolePolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_AttachRolePolicy.html) | Supported |
| detach_policy | [DetachRolePolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_DetachRolePolicy.html) | Supported |
| attached_polcies | [ListAttachedRolePolicies](https://docs.aws.amazon.com/IAM/latest/APIReference/API_ListAttachedRolePolicies.html) | Supported |

## Resource: `policy`

#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes |  The friendly name of the policy. |
| description | no | A friendly description of the policy.|
| policy_document | yes | The JSON policy document that you want to use as the content for the new policy.|
| path | no | The path for the policy. |

#### Supported Outputs
- PolicyName
- Arn
- PolicyArn


#### Usage
```
#Creates a new IAM Policy
resource "my_policy", type: "rs_aws_iam.policy" do
  name "MyTestPolicy"
  policy_document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:ListAllMyBuckets",
"Resource":"arn:aws:s3:::*"},{"Effect":"Allow","Action":["s3:Get*","s3:List*"],"Resource":
["arn:aws:s3:::EXAMPLE-BUCKET","arn:aws:s3:::EXAMPLE-BUCKET/*"]}]}'
  description "test policy description"
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreatePolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_CreatePolicy.html) | Supported |
| destroy | [DeletePolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_DeletePolicy.html) | Supported |
| get | [GetPolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_GetPolicy.html) | Supported |

## Resource: `instance_profile`

#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes |  The friendly name of the policy. |
| description | no | A friendly description of the policy.|
| policy_document | yes | The JSON policy document that you want to use as the content for the new policy.|
| path | no | The path for the policy. |

#### Supported Outputs
- PolicyName
- Arn
- PolicyArn


#### Usage
```
#Creates a new IAM Instance Profile
resource "my_instance_profile", type:"rs_aws_iam.instance_profile" do
  name "MyInstanceProfile"
  role_name @my_role.RoleName
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreatePolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_CreateInstanceProfile.html) | Supported |
| destroy | [DeletePolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_DeleteInstanceProfile.html) | Supported |
| get | [GetPolicy](https://docs.aws.amazon.com/IAM/latest/APIReference/API_GetInstanceProfile.html) | Supported |
| add_role| [AddRoleToInstanceProfile](https://docs.aws.amazon.com/IAM/latest/APIReference/API_AddRoleToInstanceProfile.html) | Supported |


## Examples
Please review [iam_test_cat.rb](./iam_test_cat.rb) for a basic example implementation.

## Known Issues / Limitations
- Currently only supports a few actions from the IAM functions.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS IAM Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.
