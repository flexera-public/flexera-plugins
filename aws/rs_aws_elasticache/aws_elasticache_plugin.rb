name 'rs_aws_elasticache'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - ElastiCache Plugin"
long_description "Version: 1.2"
package "plugins/rs_aws_elasticache"
import "sys_log"

plugin "rs_aws_elasticache" do
  endpoint do
    default_scheme "https"
    headers do {
      "content-type" => "application/xml"
    } end
    query do {
      "Version" => "2015-02-02"
    } end
  end
  
  type "cluster" do
    href_templates "/?Action=DescribeCacheClusters&CacheClusterId={{//CreateCacheClusterResult/CacheCluster/CacheClusterId}}","/?Action=DescribeCacheClusters&CacheClusterId={{//DescribeCacheClustersResult/CacheClusters/CacheCluster/CacheClusterId}}"
    provision "provision_cluster"
    delete    "delete_resource"

    field "cache_cluster_id" do
      alias_for "CacheClusterId"
      type      "string"
      location  "query"
      required true
    end

    field "auth_token" do
      alias_for "AuthToken"
      type "string"
      location "query"
    end

    field "auto_minor_version_upgrade" do
      alias_for "AutoMinorVersionUpgrade"
      type "string"
      location "query"
    end

    field "az_mode" do
      alias_for "AZMode"
      type "string"
      location "query"
    end 

    field "cache_node_type" do
      alias_for "CacheNodeType"
      type "string"
      location "query"
    end

    field "cache_parameter_group_name" do
      alias_for "CacheParameterGroupName"
      type "string"
      location "query"
    end 

    field "cache_security_group_name_1" do
      alias_for "CacheSecurityGroupNames.member.1"
      type "string"
      location "query"
    end 

    field "cache_security_group_name_2" do
      alias_for "CacheSecurityGroupNames.member.2"
      type "string"
      location "query"
    end

    field "cache_security_group_name_3" do
      alias_for "CacheSecurityGroupNames.member.3"
      type "string"
      location "query"
    end

    field "cache_security_group_name_4" do
      alias_for "CacheSecurityGroupNames.member.4"
      type "string"
      location "query"
    end

    field "cache_security_group_name_5" do
      alias_for "CacheSecurityGroupNames.member.5"
      type "string"
      location "query"
    end 

    field "cache_subnet_group_name" do
      alias_for "CacheSubnetGroupName"
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

    field "notification_topic_arn" do
      alias_for "NotificationTopicArn"
      type "string"
      location "query"
    end

    field "num_cache_nodes" do
      alias_for "NumCacheNodes"
      type "string"
      location "query"
    end

    field "port" do
      alias_for "Port"
      type "string"
      location "query"
    end

    field "preferred_availability_zone" do
      alias_for "PreferredAvailabilityZone"
      type "string"
      location "query"
    end

    field "preferred_availability_zone_1" do
      alias_for "PreferredAvailabilityZones.member.1"
      type "string"
      location "query"
    end

    field "preferred_availability_zone_2" do
      alias_for "PreferredAvailabilityZones.member.2"
      type "string"
      location "query"
    end

    field "preferred_availability_zone_3" do
      alias_for "PreferredAvailabilityZones.member.3"
      type "string"
      location "query"
    end

    field "preferred_maintenance_window" do
      alias_for "PreferredMaintenanceWindow"
      type "string"
      location "query"
    end 

    field "replication_group_id" do
      alias_for "ReplicationGroupId"
      type "string"
      location "query"
    end

    field "security_group_id_1" do
      alias_for "SecurityGroupIds.member.1"
      type "string"
      location "query"
    end

    field "security_group_id_2" do
      alias_for "SecurityGroupIds.member.2"
      type "string"
      location "query"
    end

    field "security_group_id_3" do
      alias_for "SecurityGroupIds.member.3"
      type "string"
      location "query"
    end

    field "security_group_id_4" do
      alias_for "SecurityGroupIds.member.4"
      type "string"
      location "query"
    end

    field "security_group_id_5" do
      alias_for "SecurityGroupIds.member.5"
      type "string"
      location "query"
    end

    field "snapshot_arn_1" do
      alias_for "SnapshotArns.member.1"
      type "string"
      location "query"
    end

    field "snapshot_arn_2" do
      alias_for "SnapshotArns.member.2"
      type "string"
      location "query"
    end

    field "snapshot_arn_3" do
      alias_for "SnapshotArns.member.3"
      type "string"
      location "query"
    end

    field "snapshot_name" do
      alias_for "SnapshotName"
      type "string"
      location "query"
    end

    field "snapshot_retention_limit" do
      alias_for "SnapshotRetentionLimit"
      type "string"
      location "query"
    end

    field "snapshot_window" do
      alias_for "SnapshotWindow"
      type "string"
      location "query"
    end

    field "tag_key_1" do
      alias_for "Tags.member.1.Key"
      type "string"
      location "query"
    end

    field "tag_value_1" do
      alias_for "Tags.member.1.Value"
      type "string"
      location "query"
    end

    field "tag_key_2" do
      alias_for "Tags.member.2.Key"
      type "string"
      location "query"
    end

    field "tag_value_2" do
      alias_for "Tags.member.2.Value"
      type "string"
      location "query"
    end

    field "tag_key_3" do
      alias_for "Tags.member.3.Key"
      type "string"
      location "query"
    end

    field "tag_value_3" do
      alias_for "Tags.member.3.Value"
      type "string"
      location "query"
    end

    field "tag_key_4" do
      alias_for "Tags.member.4.Key"
      type "string"
      location "query"
    end

    field "tag_value_4" do
      alias_for "Tags.member.4.Value"
      type "string"
      location "query"
    end

    field "tag_key_5" do
      alias_for "Tags.member.5.Key"
      type "string"
      location "query"
    end

    field "tag_value_5" do
      alias_for "Tags.member.5.Value"
      type "string"
      location "query"
    end

    field "tag_key_6" do
      alias_for "Tags.member.6.Key"
      type "string"
      location "query"
    end

    field "tag_value_6" do
      alias_for "Tags.member.6.Value"
      type "string"
      location "query"
    end

    field "tag_key_7" do
      alias_for "Tags.member.7.Key"
      type "string"
      location "query"
    end

    field "tag_value_7" do
      alias_for "Tags.member.7.Value"
      type "string"
      location "query"
    end

    field "tag_key_8" do
      alias_for "Tags.member.8.Key"
      type "string"
      location "query"
    end

    field "tag_value_8" do
      alias_for "Tags.member.8.Value"
      type "string"
      location "query"
    end

    field "tag_key_9" do
      alias_for "Tags.member.9.Key"
      type "string"
      location "query"
    end

    field "tag_value_9" do
      alias_for "Tags.member.9.Value"
      type "string"
      location "query"
    end

    field "tag_key_10" do
      alias_for "Tags.member.10.Key"
      type "string"
      location "query"
    end

    field "tag_value_10" do
      alias_for "Tags.member.10.Value"
      type "string"
      location "query"
    end
    
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheCluster.html
    action "create" do
      verb "POST"
      path "/?Action=CreateCacheCluster"
      output_path "//CreateCacheClusterResult/CacheCluster"
    end
    
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheCluster.html
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteCacheCluster&CacheClusterId=$CacheClusterId"

      field "final_snapshot_identifier" do
        alias_for "FinalSnapshotIdentifier"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheClusters.html
    action "get" do
      verb "POST"
      path "$href"
      output_path "//DescribeCacheClustersResult/CacheClusters/CacheCluster"
    end
    
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheClusters.html
    action "list" do
      verb "POST"
      path "/?Action=DescribeCacheClusters"
      output_path "//DescribeCacheClustersResult/CacheClusters/CacheCluster"

      field "max_records" do
        alias_for "MaxRecords"
        location "query"
      end

      field "show_cache_clusters_not_in_replication_groups" do
        alias_for "ShowCacheClustersNotInReplicationGroups"
        location "query"
      end

      field "cache_cluster_id" do
        alias_for "CacheClusterId"
        location  "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ModifyCacheCluster.html
    action "update" do
      verb "POST"
      path "/?Action=ModifyCacheCluster&CacheClusterId=$CacheClusterId"
      output_path "//ModifyCacheClusterResult/CacheCluster"

      field "apply_immediately" do
        alias_for "ApplyImmediately"
        location "query"
      end

      field "new_availability_zone_1" do
        alias_for "NewAvailabilityZones.member.1"
        location "query"
      end
  
      field "new_availability_zone_2" do
        alias_for "NewAvailabilityZones.member.2"
        location "query"
      end
  
      field "new_availability_zone_3" do
        alias_for "NewAvailabilityZones.member.3"
        location "query"
      end

      field "cache_node_id_to_remove" do
        alias_for "CacheNodeIdsToRemove.member.1"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_RebootCacheCluster.html
    action "reboot" do
      verb "POST"
      path "/?Action=RebootCacheCluster&CacheClusterId=$CacheClusterId"
      output_path "//RebootCacheClusterResult/CacheCluster"

      field "node_id_1" do
        alias_for "CacheNodeIdsToReboot.member.1"
        location "query"
      end
  
      field "node_id_2" do
        alias_for "CacheNodeIdsToReboot.member.2"
        location "query"
      end
  
      field "node_id_3" do
        alias_for "CacheNodeIdsToReboot.member.3"
        location "query"
      end
  
      field "node_id_4" do
        alias_for "CacheNodeIdsToReboot.member.4"
        location "query"
      end
  
      field "node_id_5" do
        alias_for "CacheNodeIdsToReboot.member.5"
        location "query"
      end
    end

    output "CacheClusterId","CacheClusterStatus","ClientDownloadLandingPage","CacheNodeType","Engine","PreferredAvailabilityZone","CacheClusterCreateTime","EngineVersion","AutoMinorVersionUpgrade","PreferredMaintenanceWindow","NumCacheNodes"

    output "CacheParameterGroupName" do
      body_path "/CacheParameterGroup/CacheParameterGroupName"
      type "simple_element"
    end 

    output "Address" do
      body_path "/ConfigurationEndpoint/Address"
      type "simple_element"
    end 

    output "Port" do
      body_path "/ConfigurationEndpoint/Port"
      type "simple_element"
    end 

    output "CacheSecurityGroups" do
      body_path "/CacheSecurityGroups/CacheSecurityGroup/CacheSecurityGroupName"
      type "array"
    end 

    output "NotificationArn" do
      body_path "/NotificationConfiguration/TopicArn"
      type "simple_element"
    end

  end

  type "parameter_group" do
    href_templates "/?Action=DescribeCacheParameterGroups&CacheParameterGroupName={{//CreateCacheParameterGroupResult/CacheParameterGroup/CacheParameterGroupName}}","/?Action=DescribeCacheParameterGroups&CacheParameterGroupName={{//DescribeCacheParameterGroupsResult/CacheParameterGroups/CacheParameterGroup/CacheParameterGroupName}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "cache_parameter_group_family" do
      alias_for "CacheParameterGroupFamily"
      type "string"
      location "query"
      required true
    end

    field "cache_parameter_group_name" do
      alias_for "CacheParameterGroupName"
      type "string"
      location "query"
      required true
    end

    field "description" do
      alias_for "Description"
      type "string"
      location "query"
      required true
    end 

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheParameterGroup.html
    action "create" do
      path "/?Action=CreateCacheParameterGroup"
      verb "POST"
      output_path "//CreateCacheParameterGroupResult/CacheParameterGroup"
    end 

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheParameterGroup.html
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteCacheParameterGroup&CacheParameterGroupName=$CacheParameterGroupName"
    end
 
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheParameterGroups.html
    action "get" do
      verb "POST"
      path "$href"
      output_path "//DescribeCacheParameterGroupsResult/CacheParameterGroups/CacheParameterGroup"
    end
 
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheParameterGroups.html
    action "list" do
      verb "POST"
      path "/?Action=DescribeCacheParameterGroups"
      output_path "//DescribeCacheParameterGroupsResult/CacheParameterGroups/CacheParameterGroup"

      field "cache_parameter_group_name" do
        alias_for "CacheParameterGroupName"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ModifyCacheParameterGroup.html
    action "update" do
      verb "POST"
      path "/?Action=ModifyCacheParameterGroup&CacheParameterGroupName=$CacheParameterGroupName"
      output_path "//ModifyCacheParameterGroupResult"

      field "parameter_name" do
        alias_for "ParameterNameValues.member.1.ParameterName"
        location "query"
      end
  
      field "parameter_value" do
        alias_for "ParameterNameValues.member.1.ParameterValue"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ResetCacheParameterGroup.html
    action "reset" do
      verb "POST"
      path "/?Action=ResetCacheParameterGroup&CacheParameterGroupName=$CacheParameterGroupName"
      output_path "//ResetCacheParameterGroupResult"

      field "parameter_name" do
        alias_for "ParameterNameValues.member.1.ParameterName"
        location "query"
      end
  
      field "parameter_value" do
        alias_for "ParameterNameValues.member.1.ParameterValue"
        location "query"
      end

      field "reset_all_parameters" do
        alias_for "ResetAllParameters"
        location "query"
      end
  
    end 

    output "CacheParameterGroupName","CacheParameterGroupFamily","Description"
  end

  type "security_group" do
    href_templates "/?Action=DescribeCacheSecurityGroups&CacheSecurityGroupName={{//CreateCacheSecurityGroupResult/CacheSecurityGroup/CacheSecurityGroupName}}","/?Action=DescribeCacheSecurityGroups&CacheSecurityGroupName={{//DescribeCacheSecurityGroupsResult/CacheSecurityGroups/CacheSecurityGroup/CacheSecurityGroupName}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "cache_security_group_name" do
      alias_for "CacheSecurityGroupName"
      type "string"
      location "query"
      required true
    end

    field "description" do
      alias_for "Description"
      type "string"
      location "query"
      required true
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheSecurityGroup.html
    action "create" do
      path "/?Action=CreateCacheSecurityGroup"
      verb "POST"
      output_path "//CreateCacheSecurityGroupResult/CacheSecurityGroup"
    end 

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheSecurityGroup.html
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteCacheSecurityGroup&CacheSecurityGroupName=$CacheSecurityGroupName"
    end
 
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheSecurityGroups.html
    action "get" do
      verb "POST"
      path "$href"
      output_path "//DescribeCacheSecurityGroupsResult/CacheSecurityGroups/CacheSecurityGroup"
    end
 
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheSecurityGroups.html
    action "list" do
      verb "POST"
      path "/?Action=DescribeCacheSecurityGroups"
      output_path "//DescribeCacheSecurityGroupsResult/CacheSecurityGroups/CacheSecurityGroup"

      field "cache_security_group_name" do
        alias_for "CacheSecurityGroupName"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_AuthorizeCacheSecurityGroupIngress.html
    action "authorize_ingress" do
      verb "POST"
      path "/?Action=AuthorizeCacheSecurityGroupIngress&CacheSecurityGroupName=$CacheSecurityGroupName"
      output_path "//AuthorizeCacheSecurityGroupIngressResult/CacheSecurityGroup"

      field "ec2_security_group_name" do
        alias_for "EC2SecurityGroupName"
        location "query"
      end
  
      field "ec2_security_group_owner_id" do
        alias_for "EC2SecurityGroupOwnerId"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_RevokeCacheSecurityGroupIngress.html
    action "revoke_ingress" do
      verb "POST"
      path "/?Action=RevokeCacheSecurityGroupIngress&CacheSecurityGroupName=$CacheSecurityGroupName"
      output_path "//RevokeCacheSecurityGroupIngressResult/CacheSecurityGroup"

      field "ec2_security_group_name" do
        alias_for "EC2SecurityGroupName"
        location "query"
      end
  
      field "ec2_security_group_owner_id" do
        alias_for "EC2SecurityGroupOwnerId"
        location "query"
      end
    end

    output "CacheSecurityGroupName","OwnerId","Description"

    output "EC2SecurityGroupName" do
      body_path "/EC2SecurityGroups/EC2SecurityGroup/EC2SecurityGroupName"
      type "array"
    end

    output "EC2SecurityGroupOwnerId" do
      body_path "/EC2SecurityGroups/EC2SecurityGroup/EC2SecurityGroupOwnerId"
      type "array"
    end
  end

  type "subnet_group" do
    href_templates "/?Action=DescribeCacheSubnetGroups&CacheSubnetGroupName={{//CreateCacheSubnetGroupResult/CacheSubnetGroup/CacheSubnetGroupName}}","/?Action=DescribeCacheSubnetGroups&CacheSubnetGroupName={{//DescribeCacheSubnetGroupsResult/CacheSubnetGroups/CacheSubnetGroup/CacheSubnetGroupName}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "cache_subnet_group_name" do
      alias_for "CacheSubnetGroupName"
      type "string"
      location "query"
      required true
    end

    field "description" do
      alias_for "CacheSubnetGroupDescription"
      type "string"
      location "query"
      required true
    end

    field "subnet_id_1" do
      alias_for "SubnetIds.member.1"
      type "string"
      location "query"
      required true
    end

    field "subnet_id_2" do
      alias_for "SubnetIds.member.2"
      type "string"
      location "query"
    end

    field "subnet_id_3" do
      alias_for "SubnetIds.member.3"
      type "string"
      location "query"
    end

    field "subnet_id_4" do
      alias_for "SubnetIds.member.4"
      type "string"
      location "query"
    end

    field "subnet_id_5" do
      alias_for "SubnetIds.member.5"
      type "string"
      location "query"
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CreateCacheSubnetGroup.html
    action "create" do
      path "/?Action=CreateCacheSubnetGroup"
      verb "POST"
      output_path "//CreateCacheSubnetGroupResult/CacheSubnetGroup"
    end 

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DeleteCacheSubnetGroup.html
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteCacheSubnetGroup&CacheSubnetGroupName=$CacheSubnetGroupName"
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheSubnetGroups.html
    action "get" do
      verb "POST"
      path "$href"
      output_path "//DescribeCacheSubnetGroupsResult/CacheSubnetGroups/CacheSubnetGroup"
    end
 
    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_DescribeCacheSubnetGroups.html
    action "list" do
      verb "POST"
      path "/?Action=DescribeCacheSubnetGroups"
      output_path "//DescribeCacheSubnetGroupsResult/CacheSubnetGroups/CacheSubnetGroup"

      field "cache_subnet_group_name" do
        alias_for "CacheSubnetGroupName"
        location "query"
      end
    end

    # http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_ModifyCacheSubnetGroup.html
    action "update" do
      verb "POST"
      path "/?Action=ModifyCacheSubnetGroup&CacheSubnetGroupName=$CacheSubnetGroupName"
      output_path "//ModifyCacheSubnetGroupResult/CacheSubnetGroup"
    end

    output "VpcId","CacheSubnetGroupDescription","CacheSubnetGroupName"

    output "SubnetIdentifier" do
      body_path "/Subnets/Subnet/SubnetIdentifier"
      type "array"
    end

    output "SubnetAvailabilityZone" do
      body_path "/Subnets/Subnet/SubnetAvailabilityZone/Name"
      type "array"
    end
  end

end

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

define delete_resource(@resource) do
  sub on_error: skip do
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Destroy Resource")
    call sys_log.detail(to_object(@resource))
  end
  @resource.destroy()
end

define provision_cluster(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_aws_elasticache.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    sub on_error: skip do
      sleep_until(@operation.CacheClusterStatus == "available")
    end 
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_aws_elasticache.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
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



