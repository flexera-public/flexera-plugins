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
   1. Upload the `application_lb_plugin.rb` file located in this repository
 
## How to Use
The AWS ALB Plugin has been packaged as `plugins/rs_aws_alb`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_aws_alb"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

AWS ALB resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 -  load_balancer
 -  target_group
 -  listener
 -  rule

## Usage
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
## Resources
## load_balancer
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the load balancer.|
|ip_address_type|No|The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 (for IPv4 addresses) and dualstack (for IPv4 and IPv6 addresses). Internal load balancers must use ipv4.|
|scheme|Valid Values: `internet-facing` | `internal`|
|security_group1|No|The IDs of the security groups to assign to the load balancer.|
|security_group2|No|The IDs of the security groups to assign to the load balancer.|
|security_group3|No|The IDs of the security groups to assign to the load balancer.|
|subnet1|Yes|The IDs of the subnets to attach to the load balancer. You can specify only one subnet per Availability Zone. You must specify subnets from at least two Availability Zones.|
|subnet2|Yes|The IDs of the subnets to attach to the load balancer. You can specify only one subnet per Availability Zone. You must specify subnets from at least two Availability Zones.|
|subnet3|No|The IDs of the subnets to attach to the load balancer. You can specify only one subnet per Availability Zone. You must specify subnets from at least two Availability Zones.|
|tag_value_1|No|The value of the tag|
|tag_key_1|No|The key of the tag|
|tag_value_2|No|The value of the tag|
|tag_key_2|No|The key of the tag|
|tag_value_3|No|The value of the tag|
|tag_key_3|No|The key of the tag|
|tag_value_4|No|The value of the tag|
|tag_key_4|No|The key of the tag|
|tag_value_5|No|The value of the tag|
|tag_key_5|No|The key of the tag|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | CreateLoadBalancer | Supported |
| destroy | DeleteLoadBalancer | Supported |
| list | DescribeLoadBalancers | Supported |
| register_target | RegisterTargets | Untested |
| deregister_target | DeregisterTargets | Untested |

#### Supported Outputs
- "LoadBalancerArn"
- "Scheme"
- "LoadBalancerName"
- "VpcId"
- "CanonicalHostedZoneId"
- "CreatedTime"
- "DNSName"
- "State"
- "AvailabilityZone"
- "SubnetId"
- "SecurityGroup"

## rule
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|priority|Yes|The priority for the rule. A listener can't have multiple rules with the same priority.|
|listener_arn|Yes|The Amazon Resource Name (ARN) of the listener.|
|action1_target_group_arn|Yes|The Amazon Resource Name (ARN) of the target group.|
|action1_type|Yes|An action. Each action has the type forward and specifies a target group.|
|action2_target_group_arn|No|The Amazon Resource Name (ARN) of the target group.|
|action2_type|No|An action. Each action has the type forward and specifies a target group.|
|action3_target_group_arn|No|The Amazon Resource Name (ARN) of the target group.|
|action3_type|No|An action. Each action has the type forward and specifies a target group.|
|condition1_field|Yes|The name of the field. The possible values are `host-header` and `path-pattern`.|
|condition1_value1|Yes|the condition of value: http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html|
|condition1_value2|No|the condition of value|
|condition1_value3|No|the condition of value|
|condition2_field|No|The name of the field. The possible values are `host-header` and `path-pattern`.|
|condition2_value1|No|the condition of value|
|condition2_value2|No|the condition of value|
|condition2_value3|No|the condition of value|
|condition3_field|No|The name of the field. The possible values are `host-header` and `path-pattern`.|
|condition3_value1|No|the condition of value|
|condition3_value2|No|the condition of value|
|condition3_value3|No|the condition of value|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | CreateRule | Supported |
| destroy | DeleteRule | Supported |
| list | DescribeRules | Supported |

#### Supported Outputs
- "Priority"
- "RuleArn"
- "TargetGroupArn"
- "ConditionField"
- "ConditionValue"


## target_group
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|health_check_interval_seconds|No|The approximate amount of time, in seconds, between health checks of an individual target. |
|health_check_path|No|The ping path that is the destination on the targets for health checks. The default is /.|
|health_check_port|No|The port the load balancer uses when performing health checks on targets. The default is traffic-port, which indicates the port on which each target receives traffic from the load balancer.|
|health_check_protocol|No|The protocol the load balancer uses when performing health checks on targets. The default is the HTTP protocol.|
|health_check_timeout_seconds|No|The amount of time, in seconds, during which no response from a target means a failed health check. The default is 5 seconds.|
|healthy_threshold_count|No|The number of consecutive health checks successes required before considering an unhealthy target healthy. The default is 5.|
|matcher|No|The HTTP codes to use when checking for a successful response from a target. The default is 200.|
|name|Yes|The name of the target group.|
|port|Yes|The port on which the targets receive traffic. This port is used unless you specify a port override when registering the target.|
|protocol|Yes|The protocol to use for routing traffic to the targets.|
|unhealthy_threshold_count|No|The number of consecutive health check failures required before considering a target unhealthy. The default is 2.|
|vpc_id|Yes|The identifier of the virtual private cloud (VPC).|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | CreateTargetGroup | Supported |
| destroy | DeleteTargetGroup | Supported |
| list | DescribeTargetGroups | Supported |

#### Supported Outputs
 - "TargetGroupArn"
 - "HealthCheckTimeoutSeconds"
 - "HealthCheckPort"
 - "TargetGroupName"
 - "HealthCheckProtocol"
 - "HealthCheckPath"
 - "Protocol"
 - "Port"
 - "VpcId"
 - "HealthyThresholdCount"
 - "HealthCheckIntervalSeconds"
 - "UnhealthyThresholdCount"


## listener
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|certificate_arn|No|The Amazon Resource Name (ARN) of the certificate.|
|action1_target_group_arn|Yes|The Amazon Resource Name (ARN) of the target group.|
|action1_type|Yes|The type of action:forward|
|load_balancer_arn|Yes|The Amazon Resource Name (ARN) of the load balancer.|
|port|Yes|The port on which the load balancer is listening.|
|protocol|Yes|The protocol for connections from clients to the load balancer.(Valid Values: HTTP | HTTPS)|
|ssl_policy|No|The security policy that defines which ciphers and protocols are supported. The default is the current predefined security policy.|

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | CreateListeners | Supported |
| destroy | DeleteListeners | Supported |
| list | DescribeListeners | Supported |

#### Supported Outputs
 - "LoadBalancerArn"
 - "Protocol"
 - "Port"
 - "ListenerArn"
 - "TargetGroupArn" 


## Implementation Notes
- The AWS ALB Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an ALB resource.) 
 - The most common example might be to pass a RightScale instance to attach it to the ALB or similar. Support for this functionality will need to be implemented in the application CAT.
 
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