# AWS ElastiCache Plugin

## Overview
The AWS ElastiCache Plugin integrates RightScale Self-Service with the basic functionality of the AWS ElastiCache API. 

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
   1. Upload the `aws_elasticache_plugin.rb` file located in this repository
 
## How to Use
The ElastiCache Plugin has been packaged as `plugin/rs_aws_elasticache`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_elasticache"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
 - cluster
 - parameter_group
 - security_group
 - subnet_group

## Usage
```
resource "my_param_group", type: "rs_aws_elasticache.parameter_group" do
  cache_parameter_group_name last(split(@@deployment.href, "/"))
  cache_parameter_group_family "memcached1.4"
  description last(split(@@deployment.href, "/"))
end

resource "my_sec_group", type: "rs_aws_elasticache.security_group" do
  cache_security_group_name last(split(@@deployment.href, "/"))
  description last(split(@@deployment.href, "/"))
end

resource "my_subnet_group", type: "rs_aws_elasticache.subnet_group" do
  cache_subnet_group_name last(split(@@deployment.href, "/"))
  description last(split(@@deployment.href, "/"))
  subnet_id_1 "subnet-xxxxxxxx"
  subnet_id_2 "subnet-xxxxxxxx"
end

resource "my_cluster", type: "rs_aws_elasticache.cluster" do
  cache_cluster_id last(split(@@deployment.href, "/"))
  auto_minor_version_upgrade "true"
  az_mode "cross-az"
  cache_node_type "cache.m3.medium"
  cache_parameter_group_name @my_param_group.CacheParameterGroupName
  cache_subnet_group_name @my_subnet_group.CacheSubnetGroupName
  engine "memcached"
  num_cache_nodes "2"
  preferred_availability_zone_1 "us-east-1a"
  preferred_availability_zone_2 "us-east-1b"
  preferred_maintenance_window "sun:23:00-mon:01:30"
  security_group_id_1 "sg-7dad9003"
  tag_key_1 "foo"
  tag_value_1 "bar"
end
```

## Resources
### cluster
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| cache_cluster_id | Yes | The node group (shard) identifier |
| auth_token | No | The password used to access a password protected server |
| auto_minor_version_upgrade | No | This parameter is currently disabled |
| az_mode | No | Specifies whether the nodes in this Memcached cluster are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region. |
| cache_node_type | No | The compute and memory capacity of the nodes in the node group (shard). |
| cache_parameter_group_name | No | The name of the parameter group to associate with this cache cluster. |
| cache_security_group_name_1..5 | No | A list of security group names to associate with this cache cluster. | 
| cache_subnet_group_name | No | The name of the subnet group to be used for the cache cluster. |
| engine | No | The name of the cache engine to be used for this cache cluster. |
| engine_version | No | The version number of the cache engine to be used for this cache cluster. |
| notification_topic_arn | No | The Amazon Resource Name (ARN) of the Amazon Simple Notification Service (SNS) topic to which notifications are sent. |
| num_cache_nodes | No | The initial number of cache nodes that the cache cluster has. |
| port | No | The port number on which each of the cache nodes accepts connections. |
| preferred_availability_zone | No | The EC2 Availability Zone in which the cache cluster is created. All nodes belonging to this Memcached cache cluster are placed in the preferred Availability Zone. If you want to create your nodes across multiple Availability Zones, use `preferred_availability_zone_1..3`. |
| preferred_availability_zone_1..3 | No | A list of the Availability Zones in which cache nodes are created. |
| preferred_maintenance_window | No | Specifies the weekly time range during which maintenance on the cache cluster is performed. It is specified as a range in the format ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC) |
| replication_group_id | No | The ID of the replication group to which this cache cluster should belong. |
| security_group_id_1..5 | No | One or more VPC security groups associated with the cache cluster. |
| snapshot_arn_1..3 | No | Amazon Resource Name (ARN) that uniquely identifies a Redis RDB snapshot file stored in Amazon S3 |
| snapshot_name | No | The name of a Redis snapshot from which to restore data into the new node group (shard). |
| snapshot_retention_limit | No | The number of days for which ElastiCache retains automatic snapshots before deleting them |
| snapshot_window | No | The daily time range (in UTC) during which ElastiCache begins taking a daily snapshot of your node group (shard). |
| tag_key_1..10 | No | A list of cost allocation tags to be added to this resource. |
| tag_value_1..10 | No | A list of cost allocation tags to be added to this resource. |
| final_snapshot_identifier | No | The user-supplied name of a final cache cluster snapshot. Only available on `destroy()` | 
| max_records | No | The maximum number of records to include in the response. Only available on `list()` |
| show_cache_clusters_not_in_replication_groups | No | Show only nodes that are not members of a replication group. Only avaialable on `list()` |
| apply_immediately | No | If true, this parameter causes the modifications in this request and any pending modifications to be applied, asynchronously and as soon as possible, regardless of the PreferredMaintenanceWindow setting for the cache cluster. Only available on `update()` |
| new_availability_zone_1..3 | No | The list of Availability Zones where the new Memcached cache nodes are created. Only available on `update()` |
| cache_node_id_to_remove | No | Cache node IDs to be removed. Only available on `update()` | 
| node_id_1..5 | No | A list of cache node IDs to reboot. Only available on `reboot()` | 

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateCacheCluster](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheCluster.html) | Supported |
| destroy | [DeleteCacheCluster](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheCluster.html) | Supported |
| list,get | [DescribeCacheClusters](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheClusters.html) | Supported |
| update | [ModifyCacheCluster](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ModifyCacheCluster.html) | Untested |
| reboot | [RebootCacheCluster](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_RebootCacheCluster.html) | Untested |

#### Outputs
- CacheClusterId
- CacheClusterStatus
- ClientDownloadLandingPage
- CacheNodeType
- Engine
- PreferredAvailabilityZone
- CacheClusterCreateTime
- EngineVersion
- AutoMinorVersionUpgrade
- PreferredMaintenanceWindow
- NumCacheNodes
- CacheParameterGroupName
- Address
- Port
- CacheSecurityGroups
- NotificationArn

### parameter_group
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| cache_parameter_group_family | Yes | The name of the cache parameter group family that the cache parameter group can be used with. |
| cache_parameter_group_name | Yes | A user-specified name for the cache parameter group. |
| description | Yes | A user-specified description for the cache parameter group. |
| parameter_name | No | Only available on `update()` & `reset()` |
| parameter_value | No | Only available on `update()` & `reset()` |
| reset_all_parameters | No | If true, all parameters in the cache parameter group are reset to their default values. If false, only the parameters listed by ParameterNameValues are reset to their default values. Only available on `reset()` |

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateCacheParameterGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheParameterGroup.html) | Supported |
| destroy | [DeleteCacheParameterGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheParameterGroup.html) | Supported |
| get,list | [DescribeCacheParameterGroups](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheParameterGroups.html) | Supported |
| update | [ModifyCacheParameterGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ModifyCacheParameterGroup.html) | Untested |
| reset | [ResetCacheParameterGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ResetCacheParameterGroup.html) | Untested |

#### Outputs
- CacheParameterGroupName
- CacheParameterGroupFamily
- Description

### security_group
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| cache_security_group_name | Yes | A name for the cache security group. This value is stored as a lowercase string. |
| description | Yes | A description for the cache security group. |
| ec2_security_group_name | No | The Amazon EC2 security group to be authorized for ingress to the cache security group. Only available on `authorize_ingress()` & `revoke_ingress()` |
| ec2_security_group_owner_id | No | The AWS account number of the Amazon EC2 security group owner. Only available on `authorize_ingress()` & `revoke_ingress()` |


#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateCacheSecurityGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheSecurityGroup.html) | Supported |
| destroy | [DeleteCacheSecurityGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheSecurityGroup.html) | Supported |
| get,list | [DescribeCacheSecurityGroups](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheSecurityGroups.html) | Supported |
| authorize_ingress | [AuthorizeCacheSecurityGroupIngress](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_AuthorizeCacheSecurityGroupIngress.html) | Untested |
| revoke_ingress | [RevokeCacheSecurityGroupIngress](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_RevokeCacheSecurityGroupIngress.html) | Untested |

#### Outputs
- CacheSecurityGroupName
- OwnerId
- Description
- EC2SecurityGroupName
- EC2SecurityGroupOwnerId

### subnet_group
#### Supported Fields
| Field Name | Required? | Description |
|------------|-----------|-------------|
| cache_subnet_group_name | Yes | A name for the cache subnet group. This value is stored as a lowercase string. |
| description | Yes | A description for the cache subnet group. |
| subnet_id_1 | Yes | A list of VPC subnet IDs for the cache subnet group. | 
| subnet_id_2..5 | No | A list of VPC subnet IDs for the cache subnet group. |

#### Supported Actions
| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateCacheSubnetGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheSubnetGroup.html) | Supported |
| destroy | [DeleteCacheSubnetGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheSubnetGroup.html) | Supported |
| get,list | [DescribeCacheSubnetGroups](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheSubnetGroups.html) | Supported |
| update | [ModifyCacheSubnetGroup](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ModifyCacheSubnetGroup.html) | Untested |

#### Outputs
- VpcId
- CacheSubnetGroupDescription
- CacheSubnetGroupName
- SubnetIdentifier
- SubnetAvailabilityZone

## Implementation Notes
- The AWS ElastiCache Plugin makes no attempt to support non-AWS resources. (i.e. Allow the passing the RightScale or other resources as arguments to an ElastiCache resource.) 
 
Full list of possible actions can be found on the [AWS ElastiCache API Documentation](http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/Welcome.html)

## Examples
Please review [elasticache_test_cat.rb](./elasticache_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- - Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rs_aws_elasticache" do
  plugin $rs_aws_elasticache
  host "elasticache.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'elasticache'
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
The AWS ElastiCache Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
