# AWS ALB Plugin

## Overview
The AWS ALB Plugin integrates RightScale Self-Service with the basic functionality of the AWS Application Load Balancer. 

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
  - [sys_log](sys_log.rb)

## Getting Started
**Coming Soon**

## Installation
1. Be sure your RightScale account is SelfService enabled
1. Follow the Getting Started section to create a Service Account and RightScale Credentials
1. Navigate to the appropriate SelfService portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `application_lb_plugin.rb` file located in this repository
 
## How to Use
The GCE Plugin has been packaged as `plugin/rs_aws_elb`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_alb"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

AWS ALB resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates an ALB
parameter "lb_name" do
  label "ALB Name"
  description "ALB Name"
  default "myalb-1"
  type "string"
end

resource "my_alb", type: "rs_aws_alb.load_balancer" do
  name $lb_name
  scheme "internet-facing"
  ip_address_type "ipv4"
  subnet1 "subnet-843314b8"
  security_group1 "sg-7dad9003"
  subnet2 "subnet-b357c2fb"
  tag_key_1 "foo"
  tag_value_1 "bar"
end

resource "my_tg", type: "rs_aws_alb.target_group" do
  name join(["TargetGroup-",$lb_name])
  port 80
  protocol "HTTP"
  vpc_id "vpc-8172a6f8"
end

resource "my_listener", type: "rs_aws_alb.listener" do
  action1_target_group_arn @my_tg.TargetGroupArn
  action1_type "forward"
  load_balancer_arn @my_alb.LoadBalancerArn
  port 80
  protocol "HTTP"
end 

resource "my_rule", type: "rs_aws_alb.rule" do
  action1_target_group_arn @my_tg.TargetGroupArn
  action1_type "forward"
  condition1_field "path-pattern"
  condition1_value1 "/foo/*"
  listener_arn @my_listener.ListenerArn
  priority 1
end

```

## Implementation Notes
- The AWS ALB Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an ALB resource.) 
 - The most common example might be to pass a RightScale instance to attach it to the ALB or similar. Support for this functionality will need to be implemented in the application CAT.

## Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | CreateLoadBalancer | Supported |
| destroy | DeleteLoadBalancer | Supported |
| list | DescribeLoadBalancers | Supported |
| register_target | RegisterTargets | Untested |
| deregister_target | DeregisterTargets | Untested |

Full list of possible actions can be found on the [AWS ALB API Documentation](http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/Welcome.html)
## Examples
Please review [plugin.rb](./plugin.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports CRUD and instance register/deregister functions.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS ALB Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.