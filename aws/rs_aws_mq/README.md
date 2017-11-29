# AWS MQ Plugin

## Overview
The AWS MQ Plugin integrates RightScale Self-Service with the basic functionality of the AWS MQ API. 

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
The MQ Plugin has been packaged as `plugins/rs_aws_mq`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugins/rs_aws_mq"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
- brokers
- configurations
- configuration_revisions
- users

## Usage
```
resource "my_broker", type: "rs_aws_mq.brokers" do
  broker_name join(["RightScale-",last(split(@@deployment.href, "/"))])
  host_instance_type "mq.m4.large"
  engine_type "ActiveMQ"
  engine_version "5.15.0"
  deployment_mode "SINGLE_INSTANCE"
  publicly_accessible true
  subnet_ids ["subnet-xxxxxxxx"]
  security_groups ["sg-xxxxxxxx"]
  auto_minor_version_upgrade false
  users do [{
    "password" => "MyPassword456",
    "groups" => ["admins"],
    "consoleAccess" => true,
    "username" => "jane.doe"
  }] end
end
```

## Resources
### brokers
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| broker_name | Yes | The name of the broker.  |
| auto_minor_version_upgrade | Yes | Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions. |
| configuration | No | A list of information about the configuration. |
| creator_request_id | No | The unique ID that the requester receives for the created broker. |
| deployment_mode | Yes | The deployment mode of the broker. |
| engine_type | Yes | The type of broker engine. | 
| engine_version | Yes | The version of the broker engine. |
| host_instance_type | Yes | The broker's instance type. |
| maintenance_window_start_time | No | The parameters that determine the WeeklyStartTime. |
| publicly_accessible | Yes | Enables connections from applications outside of the VPC that hosts the broker's subnets. |
| security_groups | Yes | The list of security groups (1 minimum, 125 maximum) that authorize connections to brokers. |
| subnet_ids | Yes | The list of groups (2 maximum) that define which subnets and IP ranges the broker can use from different Availability Zones. |
| users | Yes | The list of ActiveMQ users (persons or applications) who can access queues and topics. |

See the [AWS CreateBrokerInput Documentation](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-brokers.html#rest-api-brokers-attributes-createbrokerinput-table) for detailed field validation.

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [POST /v1/brokers](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-brokers.html) | Supported |
| destroy | [DELETE /v1/brokers/broker-id](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-broker.html) | Supported |
| get | [GET /v1/brokers/broker-id](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-broker.html) | Supported |
| list | [GET /v1/brokers](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-brokers.html) | Untested |
| update | [PUT /v1/brokers/broker-id](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-broker.html) | Untested |
| reboot | [POST /v1/brokers/broker-id/reboot](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-broker-reboot.html) | Untested |

#### Outputs
- brokerArn
- brokerId
- brokerName
- brokerState
- engineType
- engineVersion
- hostInstanceType
- publiclyAccessible
- autoMinorVersionUpgrade
- deploymentMode
- subnetIds
- securityGroups
- maintenanceWindowStartTime
- configurations
- users
- consoleURL
- endpoints

#### Links 
- users()

### configurations
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| engine_type | Yes | The type of broker engine. |
| engine_version | Yes | The version of the broker engine. |
| name | Yes | The name of the configuration. |
| description | No | The description of the configuration. (used in the `update()` action) |
| data | No | The base64-encoded XML configuration. (used in the `update()` action) |

See the [AWS CreateConfigurationInput Documentation](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configurations.html#rest-api-configurations-attributes-createconfigurationinput-table) for detailed field validation.

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [POST /v1/configurations](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configurations.html) | Untested |
| get | [GET /v1/configurations/configuration-id](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configuration.html) | Untested |
| list | [GET /v1/configurations](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configurations.html) | Untested |
| update | [PUT /v1/configurations/configurations-id](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configuration.html) | Untested |

#### Outputs
- id
- name
- arn
- engineType
- engineVersion
- description
- created
- latestRevision

#### Links 
- configuration_revisions()

### configuration_revisions
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| configuration_id | No | The ID of the configuration. |
| revision | No | The revision number of the configuration engine. |

See the [AWS CreateConfigurationInput Documentation](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configurations.html#rest-api-configurations-attributes-createconfigurationinput-table) for detailed field validation.

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| get & show | [GET /v1/configurations/configuration-id/revisions](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configuration-revision.html) | Untested |
| list | [GET /v1/configurations/configuration-id/revisions](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-configuration-revisions.html) | Untested |

#### Outputs
- revision
- description
- created
- configurationId
- data

#### Links 
- configuration()

### users
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| password | Yes | The password of the newly created user. |
| console_access | No | Enables access to the the ActiveMQ Web Console for the ActiveMQ user. |
| groups | No | The list of groups (20 maximum) to which the ActiveMQ user belongs. |
| username | Yes | The username of the newly created user. |
| broker_id | Yes | The broker ID where the user should be created |

See the [AWS CreateUserInput Documentation](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-user.html#rest-api-user-attributes-createuserinput-table) for detailed field validation.

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [POST /v1/brokers/broker-id/users/username](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-user.html) | Untested |
| destroy | [DELETE /v1/brokers/broker-id/users/username](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-user.html) | Untested |
| get & show | [GET /v1/brokers/broker-id/users/username](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-user.html) | Untested |
| list | [GET /v1/brokers/broker-id/users](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-user.html) | Untested |
| update | [PUT /v1/brokers/broker-id/users/username](https://docs.aws.amazon.com/amazon-mq/latest/api-reference/rest-api-user.html) | Untested |


#### Outputs
- brokerId
- username
- consoleAccess
- groups
- pending

#### Links 
- broker()

## Implementation Notes
- The AWS MQ Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an MQ resource.) 

## Examples
Please review [mq_test_cat.rb](./mq_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- - Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rs_aws_mq" do
  plugin $rs_aws_mq
  host "mq.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'mq'
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
The AWS MQ Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
