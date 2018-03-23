# AWS API Gateway Plugin

## Overview
The AWS API Gateway Plugin integrates RightScale Self-Service with the basic functionality of the AWS API Gateway API.

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


## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_efs_plugin.rb` file located in this repository

## How to Use
The AWS API GW Plugin has been packaged as `plugin/rs_aws_apigw`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_apigw"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
###

#### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|


#### Supported Outputs


#### Usage
AWS API GW resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new AWS API Gateway

```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|

#### Supported Links
| Link | Associated Resource |
|------|---------------------|


## Examples
Please review [apigw_test_cat.rb](./apigw_test_cat.rb) for a basic example implementation.

## Known Issues / Limitations
- Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rs_aws_apigw" do
  plugin $rs_aws_apigw
  host "apigateway.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'apigateway'
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
The AWS API Gateway Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.




