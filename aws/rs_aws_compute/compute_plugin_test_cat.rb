name 'AWS EC2 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"
import "plugin/rs_aws_compute"

parameter "param_region" do
  like $rs_aws_compute.param_region
end

parameter "new_size" do
  label "New Size"
  type "string"
end

output "list_vpc" do
  label 'list action'
end

output "list_route_tables" do
  label "list route tables"
end

output "volume_id" do
  label "Volume ID"
  default_value @my_volume.volumeId
end

resource "my_vpc", type: "rs_aws_compute.vpc" do
  cidr_block "10.0.0.0/16"
  instance_tenancy "default"
end

resource "my_vpc_tag", type: "rs_aws_compute.tags" do
  resource_id_1 @my_vpc.vpcId
  tag_1_key "Name"
  tag_1_value join([@@deployment.name,"-vpc"])
end

resource "my_vpc_endpoint", type: "rs_aws_compute.endpoint" do
  vpc_id @my_vpc.vpcId
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_rs_vpc", type: "rs_cm.network" do
  name "my_rs_vpc"
  cidr_block "10.0.0.0/16"
  cloud_href "/api/clouds/1"
end

resource "my_rs_vpc_tag", type: "rs_aws_compute.tags" do
  resource_id_1 @my_rs_vpc.resource_uid
  tag_1_key "Name"
  tag_1_value @@deployment.name
end

resource "my_subnet", type: "rs_cm.subnet" do
  name join([@@deployment.name, "-us-east-1a"])
  cidr_block "10.0.1.0/24"
  network_href "replace-me"
  datacenter "us-east-1a"
  cloud_href "/api/clouds/1"
end

resource "my_igw", type: "rs_cm.network_gateway" do
  name join([@@deployment.name, "-igw"])
  cloud_href "/api/clouds/1"
  type "internet"
end

resource "my_rs_vpc_endpoint", type: "rs_aws_compute.endpoint" do
  vpc_id @my_rs_vpc.resource_uid
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_nat_ip", type: "rs_cm.ip_address" do
  name @@deployment.name
  domain "vpc"
  cloud_href "/api/clouds/1"
end

resource "my_nat_gateway", type: "rs_aws_compute.nat_gateway" do
  allocation_id "replace-me"
  subnet_id @my_subnet.resource_uid
end

resource "my_volume", type: "rs_aws_compute.volume" do
  availability_zone "us-east-1a"
  size "10"
  volume_type "gp2"
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

operation "resize_volume" do
  definition "resize_volume"
end

define list_vpcs(@my_vpc) return $object,$rt_tbl do
  call rs_aws_compute.start_debugging()
  @vpcs = rs_aws_compute.vpc.list()
  $object = to_object(first(@vpcs))
  $object = to_s($object)
  @route_tables = @my_vpc.routeTables()
  $rt_tbl = to_s(to_object(@route_tables))
  call rs_aws_compute.stop_debugging()
end

define resize_volume(@my_volume,$new_size) return @my_volume do
  rs_aws_compute.volume_modification.create(volume_id: @my_volume.volumeId, size: $new_size)
end

define generated_launch(@my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint,@my_nat_ip,@my_nat_gateway,@my_subnet,@my_igw,@my_rs_vpc_tag,@my_volume,@my_vpc_tag) return @my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint,@my_nat_ip,@my_nat_gateway,@my_subnet,@my_igw,@my_rs_vpc_tag,@my_volume do
  call rs_aws_compute.start_debugging()
  sub on_error: rs_aws_compute.stop_debugging() do
    provision(@my_vpc)
    provision(@my_vpc_tag)
    @route_tables = @my_vpc.routeTables()
    $endpoint = to_object(@my_vpc_endpoint)
    $endpoint["fields"]["route_table_id_1"] = @route_tables.routeTableId
    @my_vpc_endpoint = $endpoint
    provision(@my_vpc_endpoint)
    provision(@my_rs_vpc)
    $subnet = to_object(@my_subnet)
    $subnet["fields"]["network_href"] = @my_rs_vpc.href
    @my_subnet = $subnet
    provision(@my_subnet)
    provision(@my_igw)
    @my_igw.update(network_gateway: { network_href: @my_rs_vpc.href })
    provision(@my_rs_vpc_endpoint)
    provision(@my_nat_ip)
    @aws_ip = rs_aws_compute.addresses.show(public_ip_1: @my_nat_ip.address)
    $nat_gateway = to_object(@my_nat_gateway)
    $nat_gateway["fields"]["allocation_id"] = @aws_ip.allocationId
    @my_nat_gateway = $nat_gateway
    provision(@my_nat_gateway)
    @vpc1 = rs_aws_compute.vpc.show(vpcId: @my_rs_vpc.resource_uid)
    @vpc1.enablevpcclassiclink()
    @vpc1.enablevpcclassiclinkdnssupport()
    provision(@my_rs_vpc_tag)
    @vpc1.create_tag(tag_1_key: "new_key", tag_1_value: "new_value")
    provision(@my_volume)
  end
end

define generated_terminate(@my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint,@my_nat_gateway,@my_nat_ip,@my_igw,@my_subnet) do
  delete(@my_rs_vpc_endpoint)
  delete(@my_vpc_endpoint)
  delete(@my_nat_gateway)
  delete(@my_nat_ip)
  delete(@my_igw)
  delete(@my_subnet)
  delete(@my_vpc)
  delete(@my_rs_vpc)
end