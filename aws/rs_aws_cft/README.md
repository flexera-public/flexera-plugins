# AWS CFT Plugin

## Overview
The AWS CFT Plugin integrates RightScale Self-Service with the basic functionality of the AWS CloudFormation API. 

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

### Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_cft_plugin.rb` file located in this repository
 
### How to Use
The CFT Plugin has been packaged as `plugins/rs_aws_cft`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_aws_cft"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- stack
- resources (no provision capabilities)

## Resource: `stack`

#### Supported Fields
**Note:** There are many possible configurations when defining a `stack` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed API documentation is available [here](hhttp://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/Welcome.html).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| capabilities | no * | The only valid values are `CAPABILITY_IAM` and `CAPABILITY_NAMED_IAM`. The following resources require you to specify this parameter: AWS::IAM::AccessKey, AWS::IAM::Group, AWS::IAM::InstanceProfile, AWS::IAM::Policy, AWS::IAM::Role, AWS::IAM::User, and AWS::IAM::UserToGroupAddition |
| client_request_token | no | Specify this token if you plan to retry requests so that AWS CloudFormation knows that you're not attempting to create a stack with the same name | 
| disable_rollback | no | Set to `true` to disable rollback of the stack if stack creation failed. Default value is `false`. You can specify either `on_failure` or `disable_rollback`, but not both. | 
| notification_arn_n | no | The Simple Notification Service (SNS) topic ARNs to publish stack related events.  Where `n` equals 1-3 (ie. `notification_arn_1`) |
| on_failure | no | Determines what action will be taken if stack creation fails.  Allowed Values: `DO_NOTHING`, `ROLLBACK`, or `DELETE`. You can specify either `on_failure` or `disable_rollback`, but not both. | 
| parameter_n_name | no | The key associated with the parameter. If you don't specify a key and value for a particular parameter, AWS CloudFormation uses the default value that is specified in your template. Where `n` equals 1-60 (ie. `parameter_1_name`). `parameter_1_name` and `parameter_1_value` create a hash of a single CFT parameter, etc. | | 
| parameter_n_value | no | The value associated with the parameter. Where `n` equals 1-60 (ie. `parameter_1_value`).  `parameter_1_name` and `parameter_1_value` create a hash of a single CFT parameter, etc. |
| resource_type_n | no * | The template resource types that you have permissions to work with for this create stack action. By default, AWS CloudFormation grants permissions to all resource types. AWS Identity and Access Management (IAM) uses this parameter for AWS CloudFormation-specific condition keys in IAM policies. Where `n` equals 1-3 (ie. `resource_type_1`) |
| role_arn | no | The Amazon Resource Name (ARN) of an AWS Identity and Access Management (IAM) role that AWS CloudFormation assumes to create the stack. AWS CloudFormation uses the role's credentials to make calls on your behalf. AWS CloudFormation always uses this role for all future operations on the stack. | 
| stack_name | yes | The name that is associated with the stack. The name must be unique in the region in which you are creating the stack. | 
| stack_policy_body | no | Structure containing the stack policy body. You can specify either `stack_policy_body` or `stack_policy_url`, but not both. | 
| stack_policy_url | no | Location of a file containing the stack policy. The URL must point to a policy located in an S3 bucket in the same region as the stack. You can specify either `stack_policy_body` or `stack_policy_url`, but not both. | 
| tag_key_n | no | A string used to identify a tag key.  Where `n` equals 1-50 (ie. `tag_key_1`). `tag_key_1` and `tag_value_1` create a hash of a single CFT tag, etc. |
| tag_value_n | no | A string containing the value for the associated tag key.  Where `n` equals 1-50 (ie. `tag_value_1`).  `tag_key_1` and `tag_value_1` create a hash of a single CFT tag, etc. |
| template_body | no ** | Structure containing the template body with a minimum length of 1 byte and a maximum length of 51,200 bytes. |
| template_url | no ** | Location of file containing the template body. The URL must point to a template (max size: 460,800 bytes) that is located in an Amazon S3 bucket. Examples include generating and using presigned S3 URL. | 
| timeout_in_minutes | no | The amount of time that can pass before the stack status becomes CREATE_FAILED; if `disable_rollback` is not set or is set to false, the stack will be rolled back. Note: the auto-provision definition of `stack` resources includes a 1 hour timeout.  If you need to extend that timeout, it is recommended to either edit the provision defintion in the plugin OR use a custom provision definition in your CAT. |

`*` Required if CFT includes IAM resources 
`**` One of `template_body` OR `template_url` are required, but both cannot be supplied in the same `stack` resource. 

#### Supported Outputs
- StackName
- StackId
- CreationTime
- StackStatus
- DisableRollback
- OutputKey
- OutputValue

#### Usage
AWS CFT resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new CloudFormation Stack
resource "my_stack", type: "rs_aws_cft.stack" do
  stack_name join(["cft-", last(split(@@deployment.href, "/"))])
  template_url "https://s3.amazonaws.com/rs-cft-bucket/mytemplate.template"
  timeout_in_minutes 30
  description "CFT Stack Launched from RightScale Self-Service"
  parameter_1_name  "KeyPairName"         #CFTemplate Parameter 
  parameter_1_value $param_KeyPairName    #CAT parameter value input
  parameter_2_name  "AMITOUSE"            #CFTemplate Parameter 
  parameter_2_value $param_AMITOUSE       #CAT parameter value input
  tag_key_1         CreatedBy"            #CFTemplate Parameter for Tags
  tag_value_1       $param_Tags_CreatedBy #CAT parameter value input for tag
  tag_key_2         "REGION"              #CFTemplate Parameter  for Tags
  tag_value_2       $param_Tags_REGION    #CAT parameter value input for tag
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateStack](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html) | Supported |
| destroy | [DeleteStack](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DeleteStack.html) | Supported |
| get | [DescribeStacks](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStacks.html) | Supported |
| get_stack | [DescribeStacks](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStacks.html) Note: This differs from `get()` in that it requires a `stack_name` field to be specified. (ie. `@my_stack = rs_aws_cft.stack.get_stack(stack_name: "cft-12345")` | Supported |
| update | [UpdateStack](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_UpdateStack.html) | Supported |

#### Supported Links

| Link | Associated Resource | RCL Example |
|------|---------------------|---------|
| resources() | resources | `@stack_resources = @my_stack.resources()` |

## Resource: `resources`

#### Supported Fields
**Reminder:** `create()` is not a supported action on this resource type.  The fields below can be used to filter specific Stack Resources via `get()` & `show()` actions.

| Field Name | Required? | Description |
|------------|-----------|-------------|
| stack_name | only for the `show()` action | Name of the stack of which to return the associated resources | 
| logical_resource_id | no | Logical Resource ID to filter | 
| physical_resource_id | no | Physical Resource ID to filter | 

#### Supported Outputs
- StackName
- StackId
- Timestamp
- LogicalResourceId
- PhysicalResourceId
- ResourceType
- ResourceStatus

```
#output "stackname" do
  label "CloudFormation StackName"
  default_value @stack.StackName
end

# Output the StackID
output "stackid" do
  label "CloudFormation StackId"
  default_value @stack.StackId
end

# Output the Creation Time of Stack
output "creationtime" do
  label "CloudFormation CreationTime"
  default_value @stack.CreationTime
end

# Output the Stack Status
output "stackstatus" do
  label "CloudFormation StackStatus"
  default_value @stack.StackStatus
end
```

#### Supported Links
| Link | Associated Resource | RCL Example |
|------|---------------------|---------|
| stack() | stack | `@stack = rs_aws_cft.resources.show(stack_name: "cft-12345", logical_resource_id: "my_cloudfront_distribution").stack()` |

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get | [DescribeStackResource](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackResources.html) | Supported | 
| show | [DescribeStackResources](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackResources.html) | Supported |


## Examples
Please review [cft_test_cat.rb](./cft_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rs_aws_cft" do
  plugin $rs_aws_cft
  host "cloudformation.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'cloudformation'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end
```

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS EFS Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
