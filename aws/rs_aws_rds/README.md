# AWS RDS Plugin

## Overview
The AWS RDS Plugin integrates RightScale Self-Service with the basic functionality of the AWS Relational Database Service API. 

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

## Getting Started
**Coming Soon**

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_rds_plugin.rb` file located in this repository
 
## How to Use
The RDS Plugin has been packaged as `plugin/rs_aws_rds`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_rds"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
 -  db_instance
 -  db_subnet_group

## Resource: `db_instance`

#### Supported Fields
**Note:** There are many possible configurations when defining a `db_instance` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed field documentation is available in-line within the RDS Plugin.

| Field Name | Required? | Description |
|------------|-----------|-------------|
| allocated_storage | no |  The amount of storage (in gigabytes) to be initially allocated for the database instance. |
| auto_minor_version_upgrade | no | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. |
| availability_zone | no | The EC2 Availability Zone that the database instance will be created in. |
| backup_retention_period | no | The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups. |
| character_set_name | no | For supported engines, indicates that the DB instance should be associated with the specified CharacterSet. | 
| copy_tags_to_snapshot | no | `true` to copy all tags from the DB instance to snapshots of the DB instance; otherwise `false`. |
| db_cluster_identifier | no | The identifier of the DB cluster that the instance will belong to. | 
| db_instance_class | yes* | The compute and memory capacity of the DB instance. Note that not all instance classes are available in all regions for all DB engines. |
| db_instance_identifier | yes | The DB instance identifier. This parameter is stored as a lowercase string. | 
| db_name | no | The meaning of this parameter differs according to the database engine you use.  See AWS documentation, or in-line documentation in Plugin | 
| db_parameter_group_name | no | The name of the DB parameter group to associate with this DB instance. If this argument is omitted, the default DBParameterGroup for the specified engine will be used. |
| db_security_group | no | The DB security group to associate with this DB instance. | 
| db_snapshot_identifier | yes** | The identifier for the DB snapshot to restore from. |
| db_subnet_group_name | no | A DB subnet group to associate with this DB instance. | 
| domain | no | Specify the Active Directory Domain to create the instance in. | 
| domain_IAM_role_name | no | Specify the name of the IAM role to be used when making API calls to the Directory Service. | 
| enable_IAM_db_auth | no | `true` to enable mapping of AWS Identity and Access Management (IAM) accounts to database accounts; otherwise `false`. |
| engine | yes* | The name of the database engine to be used for this instance. Valid values: mysql, mariadb, oracle-se1, oracle-se2, oracle-se, oracle-ee |
| engine_version | no | The version number of the database engine to use. |
| iops | no | The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for the DB instance. |
| kms_key_id | no | The KMS key identifier for an encrypted DB instance. |
| license_model | no | License model information for this DB instance. |
| master_username | no | The name for the master database user. | 
| master_user_password | no | The password for the master database user. Can be any printable ASCII character except "/", """, or "@". |
| monitoring_interval | no | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. |
| monitoring_role_arn | no | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. For example, arn:aws:iam:123456789012:role/emaccess. |
| multi_az | no | Specifies if the DB instance is a Multi-AZ deployment. You cannot set the `availability_zone` field if the `multi_az` field is set to true. | 
| option_group_name | no | Indicates that the DB instance should be associated with the specified option group. |
| port | no | The port number on which the database accepts connections. |
| preferred_backup_window | no | The daily time range during which automated backups are created if automated backups are enabled, using the BackupRetentionPeriod parameter |
| preferred_maintenance_window | no | The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). |
| promotion_tier | no | A value that specifies the order in which an Aurora Replica is promoted to the primary instance after a failure of the existing primary instance. |
| publicly_accessible | no | Specifies the accessibility options for the DB instance. A value of `true` specifies an Internet-facing instance with a publicly resolvable DNS name, which resolves to a public IP address. A value of `false` specifies an internal instance with a DNS name that resolves to a private IP address. |
| storage_encrypted | no | Specifies whether the DB instance is encrypted. |
| storage_type | no | Specifies the storage type to be associated with the DB instance. |
| tde_credential_arn | no | The ARN from the Key Store with which to associate the instance for TDE encryption. |
| tde_credential_password | no | The password for the given ARN from the Key Store in order to access the device. |
| timezone | no | The time zone of the DB instance. The time zone parameter is currently supported only by Microsoft SQL Server. | 
| vpc_security_group | no | EC2 VPC security group to associate with this DB instance |
| tag_key_(1-6) | no | RDS Tag Key. To be used with tag_value_(1-6) fields.  Supports up to 6 tags (ie. tag_key_1, tag_key_2, etc) | 
| tag_value_(1-6) | no | RDS Tag Value. To be used with tag_key_(1-6) fields.  Supports up to 6 tags (ie. tag_value_1, tag_value_2, etc) | 

*Not required if restoring a DB Instance from a Snapshot (ie. if a db_snapshot_identifier is set in the db_instance resource)

**Only required if restoring a DB Instance from a Snapshot

#### Supported Outputs
- BackupRetentionPeriod
- MultiAZ
- DBInstanceStatus
- DBInstanceIdentifier 
- PreferredBackupWindow 
- PreferredMaintenanceWindow 
- AvailabilityZone
- LatestRestorableTime 
- Engine 
- LicenseModel 
- PubliclyAccessible
- DBName 
- AutoMinorVersionUpgrade 
- InstanceCreateTime
- AllocatedStorage
- MasterUsername
- DBInstanceClass
- endpoint_address
- endpoint_port

#### Usage
AWS RDS resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new RDS DB Instance
resource "my_rds", type: "rs_aws_rds.db_instance" do
  allocated_storage "10" 
  availability_zone "us-east-1a"  
  db_instance_class "db.t2.small" 
  db_instance_identifier "my_rds_instance" 
  db_name "my_database" 
  db_subnet_group_name "rds-subnet-grp-12345"
  engine "mysql" 
  engine_version "5.7.11" 
  master_username "my_user"
  master_user_password "pa$$w0rd1"
  storage_encrypted "false"
  storage_type "standard"
end

#Creates a new RDS DB Instance from a DB Snapshot
resource "my_restored_rds", type: "rs_aws_rds.db_instance" do
  availability_zone "us-east-1a"
  db_instance_class "db.t2.small"
  db_instance_identifier "my_rds_instance"
  db_subnet_group_name "rds-subnet-grp-12345"
  db_snapshot_identifier "<snapshot-identifier OR snapshot-arn>"
  storage_type "standard"
end
```

There are 2 options when destroying a `db_instance` resource:
- Take a final snapshot and then delete the resource
- Skip taking a final snapshot and then delete the resource

The default is to delete the RDS DB Instance while skipping a final snapshot. Therefore this is the behavior of the the built-in `auto-terminate` operation.  To change that behavior, you can terminate the resource in a custom `terminate` operation in your CAT, using the `final_db_snapshot_identifier` field.  For example:

```
operation 'terminate' do
    definition 'terminate' 
end 

define terminate(@my_rds) do
  sub on_error: handle_error() do
    @my_rds.destroy({ "final_db_snapshot_identifier": join([@my_rds.DBInstanceIdentifier, "-final-snapshot"])})
  end
end
``` 

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html) | Supported |
| create_from_snapshot | [RestoreDBInstanceFromDBSnapshot](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_RestoreDBInstanceFromDBSnapshot.html) | Supported |
| destroy | [DeleteDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DeleteDBInstance.html) | Supported |
| list & get | [DescribeDBInstances](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DescribeDBInstances.html) | Supported |
| stop | [StopDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_StopDBInstance.html) | Supported |
| start | [StartDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_StartDBInstance.html) | Supported |
| reboot | [RebootDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_RebootDBInstance.html) | Supported |

## Resource: `db_subnet_group`

#### Supported Fields
**Note:** There are many possible configurations when defining a `db_subnet_group` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed field documentation is available in-line within the RDS Plugin.

| Field Name | Required? | Description |
|------------|-----------|-------------|
| name | yes |  The name for the DB subnet group. This value is stored as a lowercase string. |
| description | yes | The description for the DB subnet group. |
| subnet1 | yes | The EC2 Subnet IDs for the DB subnet group. |
| subnet2 | yes | The EC2 Subnet IDs for the DB subnet group. |

#### Supported Outputs
- DBSubnetGroupDescription
- DBSubnetGroupName
- name


#### Usage
```
#Creates a new RDS DB Instance
resource "drupal_rds_subnet_group", type: "rs_aws_rds.db_subnet_groups" do
  name "rds_subnet_group"
  description "RDS Subnet Group"
  subnet1 "subnet-123abcd"
  subnet2 "subnet-456efgh"
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateDBSubnetGroup](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBSubnetGroup.html) | Supported |
| destroy | [DeleteDBSubnetGroup](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DeleteDBSubnetGroup.html) | Supported |
| list & get | [DescribeDBSubnetGroups](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DescribeDBSubnetGroups.html) | Supported |

Full list of possible actions can be found on the [AWS RDS API Documentation](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_Operations.html)

## Examples
Please review [rds_test_cat.rb](./rds_test_cat.rb) for a basic example implementation.
	
## Known Issues / Limitations
- Currently only supports CRUD functions.
- Currently only supports a single region.  To support a different region, edit the `host` & `region` fields of the `resource_pool` declaration in the Plugin:
```
resource_pool "rds" do
  plugin $rs_aws_rds
  host "rds.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'rds'
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
The AWS RDS Plugin source code is subject to the MIT license, see the [LICENSE](../LICENSE) file.




