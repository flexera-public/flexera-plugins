# AWS EKS Plugin

## Overview
The AWS EKS Plugin integrates RightScale Self-Service with the basic functionality of the AWS EKS API.

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
   1. Upload the `aws_eks_plugin.rb` file located in this repository

## How to Use
The EKS Plugin has been packaged as `plugins/rs_aws_eks`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_aws_eks"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- clusters

## Usage
```
resource "my_cluster", type: "rs_aws_eks.clusters" do
  name "my_kube_cluster"
  resources_vpc_config do {
    "securityGroupIds" => ["sg-7dad9003"],
    "subnetIds" => ["subnet-b357c2fb","subnet-bb06b7e1"],
    "vpcId" => "vpc-8172a6f8"
  } end
  role_arn "arn:aws:iam::0123456789:role/EKS-Role"
  version "1.10"
end
```

## Resources
### clusters
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| client_request_token | no | Unique, case-sensitive identifier you provide to ensure the idempotency of the request. |
| name | yes | The unique name to give to your cluster. |
| resources_vpc_config | yes | The VPC subnets and security groups used by the cluster control plane. |
| role_arn | yes | The Amazon Resource Name (ARN) of the IAM role that provides permissions for Amazon EKS to make calls to other AWS API operations on your behalf.|
| version | no | The desired Kubernetes version for your cluster. If you do not specify a value here, the latest version available in Amazon EKS is used. |


#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateCluster](https://docs.aws.amazon.com/eks/latest/APIReference/API_CreateCluster.html) | Supported |
| destroy | [DeleteCluster](https://docs.aws.amazon.com/eks/latest/APIReference/API_DeleteCluster.html) | Supported |
| show | [DescribeCluster](https://docs.aws.amazon.com/eks/latest/APIReference/API_DescribeCluster.html) | Supported |
| list | [ListClusters](https://docs.aws.amazon.com/eks/latest/APIReference/API_ListClusters.html) | Untested |

#### Outputs
- endpoint
- status
- createdAt
- certificateAuthority
- arn
- roleArn
- clientRequestToken
- version
- name
- resourcesVpcConfig


## Implementation Notes
- The AWS EKS Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an EKS resource.)

## Examples
Please review [eks_test_cat.rb](./eks_test_cat.rb) for a basic example implementation.

## Known Issues / Limitations
- - Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rs_aws_eks" do
  plugin $rs_aws_eks
  host "eks.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'eks'
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
The AWS EKS Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
