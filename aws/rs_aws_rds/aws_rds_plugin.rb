name 'aws_rds_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Relational Database Service"
long_description "Version: 1.3"
package "plugins/rs_aws_rds"
import "sys_log"

plugin "rs_aws_rds" do
  endpoint do
    default_scheme "https"
    path "/"
    query do {
      "Version" => "2014-10-31"
    } end
  end

  type "db_instance" do
    href_templates "/?Action=DescribeDBInstances&DBInstanceIdentifier={{//CreateDBInstanceResult/DBInstance/DBInstanceIdentifier}}","/?Action=DescribeDBInstances&DBInstanceIdentifier={{//RestoreDBInstanceFromDBSnapshotResult/DBInstance/DBInstanceIdentifier}}","/?Action=DescribeDBInstances&DBInstanceIdentifier={{//DescribeDBInstancesResult/DBInstances/DBInstance/DBInstanceIdentifier}}"

    field "allocated_storage" do
      alias_for "AllocatedStorage"
      type "string"
      location "query"
    end 

    field "auto_minor_version_upgrade" do
      alias_for "AutoMinorVersionUpgrade"
      type "string" 
      location "query"
    end

    field "availability_zone" do
      alias_for "AvailabilityZone"
      type "string"
      location "query"
    end

    field "backup_retention_period" do
      alias_for "BackupRetentionPeriod"
      type "string"
      location "query"
    end

    field "character_set_name" do
      alias_for "CharacterSetName"
      type "string"
      location "query"
    end 

    field "copy_tags_to_snapshot" do
      alias_for "CopyTagsToSnapshot"
      type "string"
      location "query"
    end

    field "db_cluster_identifier" do
      alias_for "DBClusterIdentifier"
      type "string"
      location "query"
    end

    field "db_instance_class" do
      alias_for "DBInstanceClass"
      type "string"
      location "query"
    end

    field "db_instance_identifier" do
      alias_for "DBInstanceIdentifier"
      type "string"
      location "query"
      required true
    end

    field "db_name" do
      alias_for "DBName"
      type "string"
      location "query"
    end 

    field "db_parameter_group_name" do
      alias_for "DBParameterGroupName"
      type "string"
      location "query"
    end

    field "db_security_group" do
      alias_for "DBSecurityGroups.member.1"
      type "string"
      location "query"
    end 

    field "db_subnet_group_name" do
      alias_for "DBSubnetGroupName"
      type "string"
      location "query"
    end 

    field "domain" do
      alias_for "Domain"
      type "string"
      location "query"
    end 

    field "domain_IAM_role_name" do 
      alias_for "DomainIAMRoleName"
      type "string"
      location "query"
    end 

    field "enable_IAM_db_auth" do 
      alias_for "EnableIAMDatabaseAuthentication"
      type "string"
      location "query"
    end 

    field "engine" do
      alias_for "Engine"
      type "string"
      location "query"
    end 

    field "engine_version" do
      alias_for "EngineVersion"
      type "string"
      location "query"
    end

    field "iops" do
      alias_for "Iops"
      type "string"
      location "query"
    end 

    field "kms_key_id" do 
      alias_for "KmsKeyId"
      type "string"
      location "query"
    end 

    field "license_model" do
      alias_for "LicenseModel"
      type "string"
      location "query"
    end 

    field "master_username" do
      alias_for "MasterUsername"
      type "string"
      location "query"
    end 

    field "master_user_password" do
      alias_for "MasterUserPassword"
      type "string"
      location "query"
    end 

    field "monitoring_interval" do
      alias_for "MonitoringInterval"
      type "string"
      location "query"
    end 

    field "monitoring_role_arn" do
      alias_for "MonitoringRoleArn"
      type "string"
      location "query"
    end 

    field "multi_az" do
      alias_for "MultiAZ"
      type "string"
      location "query"
    end 

    field "option_group_name" do
      alias_for "OptionGroupName"
      type "string"
      location "query"
    end 

    field "port" do
      alias_for "Port"
      type "string"
      location "query"
    end

    field "preferred_backup_window" do
      alias_for "PreferredBackupWindow"
      type "string"
      location "query"
    end 

    field "preferred_maintenance_window" do
      alias_for "PreferredMaintenanceWindow"
      type "string"
      location "query"
    end 

    field "promotion_tier" do
      alias_for "PromotionTier"
      type "string"
      location "query"
    end 

    field "publicly_accessible" do
      alias_for "PubliclyAccessible"
      type "string"
      location "query"
    end 

    field "storage_encrypted" do
      alias_for "StorageEncrypted"
      type "string"
      location "query"
    end 

    field "storage_type" do 
      alias_for "StorageType"
      type "string"
      location "query"
    end 

    field "tde_credential_arn" do
      alias_for "TdeCredentialArn"
      type "string"
      location "query"
    end 

    field "tde_credential_password" do
      alias_for "TdeCredentialPassword"
      type "string"
      location "query"
    end 

    field "timezone" do
      alias_for "Timezone"
      type "string"
      location "query"
    end 

    field "vpc_security_group" do
      alias_for "VpcSecurityGroupIds.member.1"
      type "string"
      location "query"
    end 

    field "db_snapshot_identifier" do
      alias_for "DBSnapshotIdentifier"
      type "string"
      location "query"
    end 

    field "tag_value_1" do
      alias_for "Tags.member.1.Value"
      type "string"
      location "query"
    end 

    field "tag_key_1" do
      alias_for "Tags.member.1.Key"
      type "string"
      location "query"
    end 

    field "tag_value_2" do
      alias_for "Tags.member.2.Value"
      type "string"
      location "query"
    end 

    field "tag_key_2" do
      alias_for "Tags.member.2.Key"
      type "string"
      location "query"
    end 

    field "tag_value_3" do
      alias_for "Tags.member.3.Value"
      type "string"
      location "query"
    end 

    field "tag_key_3" do
      alias_for "Tags.member.3.Key"
      type "string"
      location "query"
    end 

    field "tag_value_4" do
      alias_for "Tags.member.4.Value"
      type "string"
      location "query"
    end 

    field "tag_key_4" do
      alias_for "Tags.member.4.Key"
      type "string"
      location "query"
    end 

    field "tag_value_5" do
      alias_for "Tags.member.5.Value"
      type "string"
      location "query"
    end 

    field "tag_key_5" do
      alias_for "Tags.member.5.Key"
      type "string"
      location "query"
    end 

    field "tag_value_6" do
      alias_for "Tags.member.6.Value"
      type "string"
      location "query"
    end 

    field "tag_key_6" do
      alias_for "Tags.member.6.Key"
      type "string"
      location "query"
    end 


    output_path "//DBInstance"

    output "BackupRetentionPeriod","MultiAZ","DBInstanceStatus","DBInstanceIdentifier","PreferredBackupWindow","PreferredMaintenanceWindow","AvailabilityZone","LatestRestorableTime","Engine","LicenseModel","PubliclyAccessible","DBName","AutoMinorVersionUpgrade","InstanceCreateTime","AllocatedStorage","MasterUsername","DBInstanceClass"

    output "endpoint_address" do
      body_path "Endpoint/Address"
    end

    output "endpoint_port" do 
      body_path "Endpoint/Port"
    end
    
    action "create" do
      verb "POST"
      path "/?Action=CreateDBInstance"
    end

    action "create_from_snapshot" do
      verb "POST"
      path "/?Action=RestoreDBInstanceFromDBSnapshot"

      field "db_snapshot_identifier" do
        alias_for "DBSnapshotIdentifier"
        location "query"
      end 

      field "auto_minor_version_upgrade" do
        alias_for "AutoMinorVersionUpgrade"
        location "query"
      end

      field "availability_zone" do
        alias_for "AvailabilityZone"
        location "query"
      end

      field "copy_tags_to_snapshot" do
        alias_for "CopyTagsToSnapshot"
        location "query"
      end

      field "db_instance_class" do
        alias_for "DBInstanceClass"
        location "query"
      end

      field "db_instance_identifier" do
        alias_for "DBInstanceIdentifier"
        location "query"
      end

      field "db_name" do
        alias_for "DBName"
        location "query"
      end 

      field "db_subnet_group_name" do
        alias_for "DBSubnetGroupName"
        location "query"
      end 

      field "domain" do
        alias_for "Domain"
        location "query"
      end 

      field "domain_IAM_role_name" do 
        alias_for "DomainIAMRoleName"
        location "query"
      end 

      field "enable_IAM_db_auth" do 
        alias_for "EnableIAMDatabaseAuthentication"
        location "query"
      end 

      field "engine" do
        alias_for "Engine"
        location "query"
      end 

      field "iops" do
        alias_for "Iops"
        location "query"
      end 

      field "license_model" do
        alias_for "LicenseModel"
        location "query"
      end 

      field "multi_az" do
        alias_for "MultiAZ"
        location "query"
      end 

      field "option_group_name" do
        alias_for "OptionGroupName"
        location "query"
      end 

      field "port" do
        alias_for "Port"
        location "query"
      end

      field "publicly_accessible" do
        alias_for "PubliclyAccessible"
        location "query"
      end 

      field "storage_type" do 
        alias_for "StorageType"
        location "query"
      end 

      field "tde_credential_arn" do
        alias_for "TdeCredentialArn"
        location "query"
      end 

      field "tde_credential_password" do
        alias_for "TdeCredentialPassword"
        location "query"
      end 

      field "tag_value_1" do
        alias_for "Tags.member.1.Value"
        location "query"
      end 

      field "tag_key_1" do
        alias_for "Tags.member.1.Key"
        location "query"
      end 

      field "tag_value_2" do
        alias_for "Tags.member.2.Value"
        location "query"
      end 

      field "tag_key_2" do
        alias_for "Tags.member.2.Key"
        location "query"
      end 

      field "tag_value_3" do
        alias_for "Tags.member.3.Value"
        location "query"
      end 

      field "tag_key_3" do
        alias_for "Tags.member.3.Key"
        location "query"
      end 

      field "tag_value_4" do
        alias_for "Tags.member.4.Value"
        location "query"
      end 

      field "tag_key_4" do
        alias_for "Tags.member.4.Key"
        location "query"
      end 

      field "tag_value_5" do
        alias_for "Tags.member.5.Value"
        location "query"
      end 

      field "tag_key_5" do
        alias_for "Tags.member.5.Key"
        location "query"
      end 

      field "tag_value_6" do
        alias_for "Tags.member.6.Value"
        location "query"
      end 

      field "tag_key_6" do
        alias_for "Tags.member.6.Key"
        location "query"
      end 


    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteDBInstance"

      field "skip_final_snapshot" do
        alias_for "SkipFinalSnapshot"
        location "query"
      end 

      field "final_db_snapshot_identifier" do
        alias_for "FinalDBSnapshotIdentifier"
        location "query"
      end 

    end
 
    action "get" do
      verb "POST"
      path "$href?Action=DescribeDBInstances"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeDBInstances"
    end

    action "stop" do
      verb "POST"
      path "$href?Action=StopDBInstance"

      field "db_snapshot_identifier" do
        alias_for "DBSnapshotIdentifier"
        location "query"
      end 
    end 

    action "start" do
      verb "POST"
      path "$href?Action=StartDBInstance"
    end 

    action "reboot" do 
      verb "POST"
      path "$href?Action=RebootDBInstance"
    end 

    provision 'provision_db_instance'
    
    delete    'delete_db_instance'
  end 

 
  type "security_groups" do
    href_templates "/?Action=DescribeDBSecurityGroups&DBSecurityGroupName={{//DescribeDBSecurityGroupsResult/DBSecurityGroups/DBSecurityGroup/DBSecurityGroupName}}","/?Action=DescribeDBSecurityGroups&DBSecurityGroupName={{//CreateDBSecurityGroupResult/DBSecurityGroup/DBSecurityGroupName}}"

    field "name" do
      alias_for "DBSecurityGroupName"
      type      "string"
      location  "query"
    end
 
    field "description" do
      alias_for "DBSecurityGroupDescription"
      type      "string"
      location  "query"
    end
 
    output_path "//DBSecurityGroup"
 
    output 'DBSecurityGroupDescription' do
      body_path "DBSecurityGroupDescription"
      type "simple_element"
    end

    output 'OwnerId' do
      body_path "OwnerId"
      type "simple_element"
    end

    output 'DBSecurityGroupName' do
      body_path 'DBSecurityGroupName'
      type "simple_element"
    end 

    action "create" do
      verb "POST"
      path "/?Action=CreateDBSecurityGroup"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteDBSecurityGroup"
    end
 
    action "get" do
      verb "POST"
      path "/?Action=DescribeDBSecurityGroups"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeDBSecurityGroups"
    end

    provision "provision_sg"

    delete    "delete_sg"

  end

  type "db_subnet_groups" do
    href_templates "/?Action=DescribeDBSubnetGroups&DBSubnetGroupName={{//CreateDBSubnetGroupResult/DBSubnetGroup/DBSubnetGroupName}}","/?Action=DescribeDBSubnetGroups&DBSubnetGroupName={{//DescribeDBSubnetGroupsResult/DBSubnetGroups/DBSubnetGroup/DBSubnetGroupName}}"

    field "name" do
      alias_for "DBSubnetGroupName"
      type      "string"
      location  "query"
    end

    field "description" do
      alias_for "DBSubnetGroupDescription"
      type      "string"
      location  "query"
    end
    
    field "subnet1" do
      alias_for "SubnetIds.member.1"
      type "string"
      location "query"
    end

    field "subnet2" do
      alias_for "SubnetIds.member.2"
      type "string"
      location "query"
    end

    output_path "//DBSubnetGroup"

    output "DBSubnetGroupDescription" do
      body_path "DBSubnetGroupDescription"
      type "simple_element"
    end

    output "DBSubnetGroupName" do
      body_path "DBSubnetGroupName"
      type "simple_element"
    end

    output "name" do
      body_path "DBSubnetGroupName"
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateDBSubnetGroup"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteDBSubnetGroup"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeDBSubnetGroups"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeDBSubnetGroups"
    end

    provision "provision_db_subnet_group"

    delete    "delete_db_subnet_group"

  end
end

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

define provision_db_instance(@declaration) return @db_instance do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    if $fields["db_snapshot_identifier"] != null 
      @db_instance = rs_aws_rds.db_instance.create_from_snapshot($fields)
    else
      @db_instance = rs_aws_rds.db_instance.create($fields)
    end
    sub on_error: skip do
      sleep_until(@db_instance.DBInstanceStatus == "available")
    end 
    @db_instance = @db_instance.get()
    call stop_debugging()
  end
end

define handle_retries($attempts) do
  if $attempts <= 6
    sleep(10*to_n($attempts))
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end

define delete_db_instance(@db_instance) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    call start_debugging()
    if @db_instance.DBInstanceStatus != "deleting"
      @db_instance.destroy({ "skip_final_snapshot": "true" })
    end
    call stop_debugging()
  end 
end

define provision_sg(@declaration) return @sec_group do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    @sec_group = rs_aws_rds.security_groups.create($fields)
    @sec_group = @sec_group.get()
    call stop_debugging()
  end
end

define delete_sg(@sec_group) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    @sec_group.destroy()
  end
end

define provision_db_subnet_group(@declaration) return @db_subnet_group do
  $object = to_object(@declaration)
  $fields = $object["fields"]
  @db_subnet_group = rs_aws_rds.db_subnet_groups.create($fields)
  @db_subnet_group = @db_subnet_group.get()
end

define delete_db_subnet_group(@db_subnet_group) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    @db_subnet_group.destroy()
  end
end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end