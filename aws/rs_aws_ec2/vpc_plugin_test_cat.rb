name 'AWS VPC Test CAT'
rs_ca_ver 20161221
short_description "AWS VPC Test - Test CAT"
import "sys_log"
import "plugin/rs_aws_vpc"

output "list_vpc" do
  label 'list action'
end

output "list_route_tables" do
  label "list route tables"
end

resource "my_vpc", type: "rs_aws_vpc.vpc" do
  cidr_block "10.0.0.0/16"
  instance_tenancy "default"
end

resource "my_vpc_endpoint", type: "rs_aws_vpc.endpoint" do
  vpc_id @my_vpc.vpcId
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_rs_vpc", type: "rs_cm.network" do
  name "my_rs_vpc"
  cidr_block "10.0.0.0/16"
  cloud_href "/api/clouds/1"
end

resource "my_rs_vpc_endpoint", type: "rs_aws_vpc.endpoint" do
  vpc_id @my_rs_vpc.resource_uid
  service_name "com.amazonaws.us-east-1.s3"
end

operation 'list_vpc' do
  definition 'list_vpcs'
  output_mappings do{
    $list_vpc => $object,
    $list_route_tables => $rt_tbl
  } end
end

operation "launch" do
  definition "generated_launch"
end

operation "terminate" do
  definition "generated_terminate"
end

define list_vpcs(@my_vpc) return $object,$rt_tbl do
  call rs_aws_vpc.start_debugging()
  @vpcs = rs_aws_vpc.vpc.list()
  $object = to_object(first(@vpcs))
  $object = to_s($object)
  @route_tables = @my_vpc.routeTables()
  $rt_tbl = to_s(to_object(@route_tables))
  call rs_aws_vpc.stop_debugging()
end

define generated_launch(@my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint) return @my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint do
  provision(@my_vpc)
  @route_tables = @my_vpc.routeTables()
  $endpoint = to_object(@my_vpc_endpoint)
  $endpoint["fields"]["route_table_id_1"] = @route_tables.routeTableId
  @my_vpc_endpoint = $endpoint
  provision(@my_vpc_endpoint)
  provision(@my_rs_vpc)
  provision(@my_rs_vpc_endpoint)
end

define generated_terminate(@my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint) do
  delete(@my_rs_vpc_endpoint)
  delete(@my_vpc_endpoint)
  delete(@my_vpc)
  delete(@my_rs_vpc)
end