# Azure SQL Database Plugin

## Overview
The Azure SQL Database Plugin integrates RightScale Self-Service with the basic functionality of the Azure SQL Database

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- Admin rights to a RightScale account with SelfService enabled
  - Admin is needed to set/retrieve the RightScale Credentials for the Azure API.
- Azure Account credentials with the appropriate permissions to manage SQL Resources
- The following RightScale Credentials
  - `AZURE_APPLICATION_ID`
  - `AZURE_APPLICATION_KEY`
  - `AZURE_TENANT_ID`
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
   1. Upload the `azure_sql_plugin.rb` file located in this repository
 
## How to Use
The Azure SQL Database Plugin has been packaged as `plugins/rs_azure_sql`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_azure_sql"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

Azure SQL Database resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

## Supported Resources
 - sql_server
 - databases
 - transparent_data_encryption
 - firewall_rule
 - elastic_pool
 - auditing_policy
 - security_policy

## Usage
```
#Creates an SQL Server and DB

parameter "subscription_id" do
  like $rs_azure_sql.subscription_id
end

resource "sql_server", type: "rs_azure_sql.sql_server" do
  name join(["my-sql-server-", last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  location "Central US"
  properties do {
      "version" => "12.0",
      "administratorLogin" =>"rightscale",
      "administratorLoginPassword" => "RightScale2017"
  } end
end

resource "database", type: "rs_azure_sql.databases" do
  name "sample-database"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

resource "transparent_data_encryption", type: "rs_azure_sql.transparent_data_encryption" do
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "status" => "Disabled"
  } end
end

resource "firewall_rule", type: "rs_azure_sql.firewall_rule" do
  name "sample-firewall-rule"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  properties do {
    "startIpAddress" => "0.0.0.1",
    "endIpAddress" => "0.0.0.1"
  } end
end

resource "elastic_pool", type: "rs_azure_sql.elastic_pool" do
  name "sample-elastic-pool"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
end

resource "auditing_policy", type: "rs_azure_sql.auditing_policy" do
  name "sample-auditing-policy"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "state" => "Enabled",
    "storageAccountAccessKey" => cred("storageAccountAccessKey"),
    "storageEndpoint" => cred("storageEndpoint")
  } end
end

resource "security_policy", type: "rs_azure_sql.security_policy" do
  name "sample-security-policy"
  resource_group "DF-Testing"
  location "Central US"
  server_name @sql_server.name
  database_name @database.name
  properties do {
    "state" => "Enabled",
    "storageAccountAccessKey" => cred("storageAccountAccessKey"),
    "storageEndpoint" => cred("storageEndpoint")
  } end
end
```
## Resources
## sql_server
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
|name|Yes|The name of the sql server.|
|resource_group|Yes|Name of resource group in which to launch the Deployment|
|location|Yes|Datacenter to launch in|
|properties|Yes|Hash of Deployment properties (https://docs.microsoft.com/en-us/rest/api/sql/servers#Servers_CreateOrUpdate)|

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
- The Azure SQL Database Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an ALB resource.) 
 - The most common example might be to pass a RightScale instance to attach it to the ALB or similar. Support for this functionality will need to be implemented in the application CAT.
 
Full list of possible actions can be found on the [Azure SQL Database API Documentation](http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/Welcome.html)
## Examples
Please review [plugin.rb](./plugin.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports CRUD and instance register/deregister functions.

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The Azure SQL Database Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.