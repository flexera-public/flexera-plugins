# AWS ELB Plugin

## Overview
The AWS ELB Plugin integrates RightScale Self-Service with the basic functionality of the AWS Elastic Load Balancer. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- Admin rights to a RightScale account with SelfService enabled
  - Admin is needed to set/retrieve the RightScale Credentials for the GCE API.
- AWS Account credentials with the appropriate permissions to manage elastic load balancers
- The following RightScale Credentials
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../libraries/sys_log.rb)

## Getting Started
**Coming Soon**

## Installation
1. Be sure your RightScale account is SelfService enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate SelfService portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_elb_plugin.rb` file located in this repository
 
## How to Use
The ELB Plugin has been packaged as `plugin/rs_aws_elb`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_elb"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

AWS ELB resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates an ELB
resource "my_elb", type: "rs_aws_elb.elb" do
  name "my-elb"
  list_lbport "80"
  list_instport "80"
  list_proto "http"
  list_instproto "http"
  subnets "<subnet_id>"
  security_groups "<sg_id>"
  description "Example address created by the AWS ELB Plugin"
end
```

## Implementation Notes
- The AWS ELB Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an ELB resource.) 
 - The most common example might be to pass a RightScale instance to attach it to the ELB or similar. Support for this functionality will need to be implemented in the application CAT.

## Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | CreateLoadBalancer | Supported |
| destroy | DeleteLoadBalancer | Supported |
| get,list,show | DescribeLoadBalancers | Supported |
| register_instance | RegisterInstancesWithLoadBalancer | Supported |
| deregister_instance | DeregisterInstancesWithLoadBalancer | Untested |
| set_certificate | SetLoadBalancerListenerSSLCertificate | Untested |

Full list of possible actions can be found on the [AWS ELB API Documentation](http://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_Operations.html)
## Examples
Please review [elb_plugin.rb](./elb_plugin.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "elb_pool" do
  plugin $rs_aws_elb
  host "elasticloadbalancing.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'elasticloadbalancing'
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
The AWS ELB Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.
