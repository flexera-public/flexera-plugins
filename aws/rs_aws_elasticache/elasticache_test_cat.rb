name 'ElastiCache Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - ElastiCache"
import "plugins/rs_aws_elasticache"

resource "my_param_group", type: "rs_aws_elasticache.parameter_group" do
  cache_parameter_group_name join(["df-",last(split(@@deployment.href, "/"))])
  cache_parameter_group_family "memcached1.4"
  description join(["df-",last(split(@@deployment.href, "/"))])
end

resource "my_sec_group", type: "rs_aws_elasticache.security_group" do
  cache_security_group_name join(["df-",last(split(@@deployment.href, "/"))])
  description join(["df-",last(split(@@deployment.href, "/"))])
end

resource "my_subnet_group", type: "rs_aws_elasticache.subnet_group" do
  cache_subnet_group_name join(["df-",last(split(@@deployment.href, "/"))])
  description join(["df-",last(split(@@deployment.href, "/"))])
  subnet_id_1 "subnet-843314b8"
  subnet_id_2 "subnet-b357c2fb"
end

resource "redis_param_group", type: "rs_aws_elasticache.parameter_group" do
  cache_parameter_group_name join(["redis-",last(split(@@deployment.href, "/"))])
  cache_parameter_group_family "redis2.8"
  description join(["redis-",last(split(@@deployment.href, "/"))])
end

resource "redis_cluster", type: "rs_aws_elasticache.cluster" do
  cache_cluster_id join(["redis-",last(split(@@deployment.href, "/"))])
  auto_minor_version_upgrade "true"
  az_mode "single-az"
  cache_node_type "cache.m3.medium"
  cache_parameter_group_name @redis_param_group.CacheParameterGroupName
  cache_subnet_group_name @my_subnet_group.CacheSubnetGroupName
  engine "redis"
  engine_version "2.8.24"
  num_cache_nodes "1"
  preferred_availability_zone_1 "us-east-1a"
  preferred_maintenance_window "sun:23:00-mon:01:30"
  security_group_id_1 "sg-7dad9003"
  tag_key_1 "foo"
  tag_value_1 "bar"
end

resource "mem_cluster", type: "rs_aws_elasticache.cluster" do
  cache_cluster_id join(["mem-",last(split(@@deployment.href, "/"))])
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

operation "terminate" do
  definition "terminate"
end

define terminate(@my_param_group,@my_subnet_group,@my_sec_group,@mem_cluster,@redis_cluster) do
  delete(@mem_cluster)
  delete(@redis_cluster)
  sleep(600)
  concurrent do
    delete(@my_param_group)
    delete(@my_sec_group)
    delete(@my_subnet_group)
  end
end
