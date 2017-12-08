# AWS Lambda Plugin

## Overview
The AWS Lambda Plugin integrates RightScale Self-Service with the basic functionality of the AWS Lambda API. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- The following RightScale Credentials
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_lambda_plugin.rb` file located in this repository
 
## How to Use
The Lambda Plugin has been packaged as `plugins/rs_aws_lambda`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_aws_lambda"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- function

## Usage
```
resource "my_function", type: "rs_aws_lambda.function" do
  function_name last(split(@@deployment.href, "/"))
  description join(["launched from SS - ", last(split(@@deployment.href, "/"))])
  runtime "nodejs6.10"
  handler "hello-world.handler"
  role "arn:aws:iam::xxxxxxxxxxxx:role/lambda_basic_execution"
  code do {
    "S3Bucket" => "Bucket_Name",
    "S3Key" => "zip_file.zip"
  } end  
end
```

## Resources
### function
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| code | Yes | The code for the Lambda function. See [FunctionCode Object Documentation](http://docs.aws.amazon.com/lambda/latest/dg/API_FunctionCode.html) for more information. |
| dead_letter_config | No | The parent object that contains the target ARN (Amazon Resource Name) of an Amazon SQS queue or Amazon SNS topic. See [DeadLetterConfig Object Documentation](http://docs.aws.amazon.com/lambda/latest/dg/API_DeadLetterConfig.html) for more information. |
| description | No | A short, user-defined function description. Lambda does not use this value. Assign a meaningful description as you see fit. |
| environment | No | The parent object that contains your environment's configuration settings. See [Environment Object Documentation](http://docs.aws.amazon.com/lambda/latest/dg/API_Environment.html) for more information. |
| function_name | Yes | The name you want to assign to the function you are uploading. |
| handler | Yes | The function within your code that Lambda calls to begin execution. | 
| kms_key_arn | No | The Amazon Resource Name (ARN) of the KMS key used to encrypt your function's environment variables. If not provided, AWS Lambda will use a default service key. |
| memory_size | No | The amount of memory, in MB, your Lambda function is given. The default value is 128 MB. The value must be a multiple of 64 MB. |
| publish | No | This boolean parameter can be used to request AWS Lambda to create the Lambda function and publish a version as an atomic operation. |
| role | Yes | The Amazon Resource Name (ARN) of the IAM role that Lambda assumes when it executes your function to access any other Amazon Web Services (AWS) resources. |
| runtime | Yes | The runtime environment for the Lambda function you are uploading. Valid Values: nodejs, nodejs4.3, nodejs6.10, java8, python2.7, python3.6, dotnetcore1.0, nodejs4.3-edge |
| tags | No | The list of tags (key-value pairs) assigned to the new function. |
| timeout | No | The function execution time at which Lambda should terminate the function. |
| tracing_config | No | The parent object that contains your function's tracing settings. See [TracingConfig Object Documentation](http://docs.aws.amazon.com/lambda/latest/dg/API_TracingConfig.html) for more information. |
| vpc_config | No | If your Lambda function accesses resources in a VPC, you provide this parameter identifying the list of security group IDs and subnet IDs. These must belong to the same VPC. You must provide at least one security group and one subnet ID. See [VpcConfig Object Documentation](http://docs.aws.amazon.com/lambda/latest/dg/API_VpcConfig.html) for more information. |

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateFunction](http://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html) | Supported |
| destroy,destroy_version | [DeleteFunction](http://docs.aws.amazon.com/lambda/latest/dg/API_DeleteFunction.html) | Supported |
| get | [GetFunction](http://docs.aws.amazon.com/lambda/latest/dg/API_GetFunction.html) | Supported |
| list | [ListFunctions](http://docs.aws.amazon.com/lambda/latest/dg/API_ListFunctions.html) | Untested |
| get_code | [GetFunction](http://docs.aws.amazon.com/lambda/latest/dg/API_GetFunction.html) | Supported |
| update_code | [UpdateFunctionCode](http://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionCode.html) | Untested |
| update_config | [UpdateFunctionConfiguration](http://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionConfiguration.html) | Untested |
| invoke | [Invoke](http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html) | Supported |

#### Outputs
- CodeSha256
- CodeSize
- Description
- FunctionArn
- FunctionName
- Handler
- KMSKeyArn
- LastModified
- MasterArn
- MemorySize
- Role
- RuntimeTimeout
- Version
- DeadLetterConfig
- EnvironmentErrorCode
- EnvironmentErrorMessage
- EnvironmentVariables
- TracingConfigMode
- SecurityGroupIds
- SubnetIds
- VpcId

## Implementation Notes
- The AWS Lambda Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an Lambda resource.) 
 
Full list of possible actions can be found on the [AWS Lambda API Documentation](http://docs.aws.amazon.com/lambda/latest/dg/API_Reference.html)

## Examples
Please review [lambda_test_cat.rb](./lambda_test_cat.rb) for a basic example implementation.

See the [lambda-optima-markups](https://github.com/rs-services/lambda-optima-markups) repo for a more complex example implementation.
	
## Known Issues / Limitations
- - Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rs_aws_lambda" do
  plugin $rs_aws_lambda
  host "lambda.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'lambda'
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
The AWS Lambda Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
