# AWS CloudFront Plugin

## Overview
The AWS CloudFront Plugin integrates RightScale Self-Service with the basic functionality of the AWS Elastic File System API.

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
   1. Upload the `aws_cloudfront_plugin.rb` file located in this repository

## How to Use
The CloudFront Plugin has been packaged as `plugin/rs_aws_cloudfront`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_cloudfront"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
### distribution

#### Supported Fields

| Field Name | Required? | Description |
|------------|-----------|-------------|
|distribution_config| yes | [See Documentation](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CreateDistribution.html#cloudfront-CreateDistribution-request-DistributionConfig)

#### Supported Outputs
- ActiveTrustedSigners
- ARN
- DistributionConfig
- DomainName
- Id
- InProgressInvalidationBatches
- LastModifiedTime
- Status

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create() | [CreateDistribution](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CreateDistribution.html) | supported
| get() | [GetDistribution](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_GetDistribution.html) | supported
| list() | [ListDistribution](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_ListDistributions.html) | not tested
| show() | [GetDistribution](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_GetDistribution.html) | supported
| destroy() | [DeleteDistribution](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_DeleteDistribution.html) | supported
| update() | [UpdateDistribution](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_UpdateDistribution.html) | supported

## Examples
Please review [cloudfront_test_cat.rb](./cloudfront_test_cat.rb) for a basic example implementation.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS cloudfront Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.




