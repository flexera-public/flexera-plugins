# AWS RDS Plugin

**Important: This plugin is currently in a Pre-Alpha state and should not be used in production**

## Overview
The AWS RDS Plugin integrates RightScale Self-Service with the basic functionality of the AWS Relational Database Service API. 

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `ss_designer` & `ss_actor` roles, in a RightScale account with SelfService enabled
- AWS Account credentials with the appropriate permissions to manage elastic load balancers
- The following RightScale Credentials
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Getting Started
**Comming Soon**

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

AWS RDS resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resrouce can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.
```
#Creates a new RDS DB Instance
resource "my_rds", type: "rs_aws_rds.db_instance" do
  allocated_storage "10" # number in GB
  zone "us-east-1a"  # availability zone (must match the region specified in the plugin)
  db_instance_type "db.t2.small" # full list of supported DB Instance Classes listed in plugin
  db_instance_identifier "my_rds_instance" # identifier/name of DB Instance
  db_name "my_database" # database name
  db_subnet_group "<rds-subnet-group-name>"
  engine "mysql" # full list of supported engines listed in plugin
  engine_version "5.7.11" # full list of supported engine versions listed in plugin
  master_username "my_user"
  master_password "pa$$w0rd1"
  storage_encrypted "false"
  storage_type "standard"
end

#Creates a new RDS DB Instance from a DB Snapshot
resource "my_rds", type: "rs_aws_rds.db_instance" do
  zone "us-east-1a"
  db_instance_type "db.t2.small"
  db_instance_identifier "my_rds_instance"
  db_subnet_group "<rds-subnet-group-name>"
  db_snapshot_identifier "<snapshot-identifier OR snapshot-arn>"
  storage_type "standard"
end

```

## Implementation Notes


## Supported Actions

| Resource | Action | API Implementation | Support Level |
|----------|--------------|:----:|:-------------:|
| RDS DB Instance | create | [CreateDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html) | Supported |
| RDS DB Instance | destroy | [DeleteDBInstance](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DeleteDBInstance.html) | Supported |
| RDS DB Instance | list & get | [DescribeDBInstances](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DescribeDBInstances.html) | Supported |
| RDS DB Instance | create_from_snapshot | [RestoreDBInstanceFromDBSnapshot](http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_RestoreDBInstanceFromDBSnapshot.html) | Supported |

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

### TODO
- Add high-valued remaining RDS resource types (ie DB Instance Cluster, Snapshots, etc)
- Add high-valued remaining RDS actions (ie `RebootDBInstance`, `CreateDBSnapshot`, etc)


