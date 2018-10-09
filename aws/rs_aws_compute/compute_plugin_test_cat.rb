name 'AWS EC2 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"
import "plugin/rs_aws_compute"

parameter "param_region" do
  like $rs_aws_compute.param_region
  description "json:{\"definition\":\"getZones\", \"description\": \"The region in which the resources are created\"}"
end

parameter "new_size" do
  label "New Size"
  type "string"
end

parameter "param_instance_id" do
  label "Instance Id"
  type "string"
end

parameter "param_image_name" do
  label "Image Name"
  type "string"
end

parameter "param_image_description" do
  label "Image Description"
  type "string"
end

parameter "param_ami_id" do
  label "AMI Id"
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

output "output_instance_id" do
  label "InstanceId"
  default_value $instance_id
end

output "output_dns_name" do
  label "DNS Id"
  default_value $instance_dns_name
end

output "output_ami_id" do
  label "AMI Id"
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
  name join([@@deployment.name, "-us-east-1b"])
  cidr_block "10.0.1.0/24"
  network @my_rs_vpc
  datacenter "us-east-1b"
  cloud_href "/api/clouds/1"
end

resource "my_sg", type: "rs_cm.security_group" do
  name join([@@deployment.name, "-default"])
  network @my_rs_vpc
  cloud_href "/api/clouds/1"
end

resource "my_igw", type: "rs_cm.network_gateway" do
  name join([@@deployment.name, "-igw"])
  cloud_href "/api/clouds/1"
  type "internet"
  network @my_rs_vpc
end

resource "my_rt_igw", type: "rs_cm.route" do
  description "internet route"
  destination_cidr_block "0.0.0.0/0"
  next_hop_network_gateway @my_igw
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

resource 'server1', type: 'rs_cm.server' do
  name "server-1"
  cloud "EC2 us-east-1"
  server_template "RightLink 10.6.0 Linux Base"
  instance_type "t2.medium"
  network @my_rs_vpc
  subnets [@my_subnet]
  security_groups [ @my_sg ]
  associate_public_ip_address true
end

operation 'list_vpc' do
  definition 'list_vpcs'
  output_mappings do {
    $list_vpc => $object,
    $list_route_tables => $rt_tbl
  } end
end

operation "launch" do
  definition "generated_launch"
  output_mappings do {
    $output_instance_id => $instance_id,
    $output_dns_name => $instance_dns_name
  } end
end

operation "terminate" do
  definition "generated_terminate"
end

operation "resize_volume" do
  definition "resize_volume"
end

operation "snapshot_root_volume" do
  definition "snapshot_root_volume"
  output_mappings do {
    $output_ami_id => $ami_id
  } end
end

operation "op_deregister_image" do
  definition "deregister_image"
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

define resize_volume($param_region,@my_volume,$new_size) return @my_volume do
  rs_aws_compute.volume_modification.create(volume_id: @my_volume.volumeId, size: $new_size)
end

define snapshot_root_volume($param_region, $param_instance_id, $param_image_name, $param_image_description) return $ami_id do
  call rs_aws_compute.start_debugging()
  $ami_id = 111
  sub on_error: stop_debugging() do
    @instance = rs_aws_compute.instances.show(instance_id: $param_instance_id)
    @image = @instance.create_image(name: $param_image_name, description: $param_description)
    $ami_id = @image.imageId
  end
  call rs_aws_compute.stop_debugging()
end

define deregister_image($param_region,$param_ami_id) do
  call rs_aws_compute.start_debugging()
  sub on_error: stop_debugging() do
    @image = rs_aws_compute.images.show(image_id: $param_ami_id)
    @image.deregister_image()
  end
  call rs_aws_compute.stop_debugging()
end
define handle_retries($attempts) do
  if $attempts <= 10
    sleep(60)
    $_error_behavior = "retry"
  else
    $_error_behavior = "skip"
  end
end

define generated_launch($param_region,@my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint,@my_nat_ip,@my_nat_gateway,@my_subnet,@my_igw,@my_rs_vpc_tag,@my_volume,@my_vpc_tag,@my_sg,@my_rt_igw,@server1) return @my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint,@my_nat_ip,@my_nat_gateway,@my_subnet,@my_igw,@my_rs_vpc_tag,@my_volume,@my_sg,@my_rt_igw,@instance,$instance_dns_name,$instance_id,@server1 do
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
    provision(@my_sg)
    @default_route_table = rs_cm.route_table.empty()
    $attempts = 0
    sub on_error: handle_retries($attempts), timeout: 60m do
      $attempts = $attempts + 1
      @default_route_table = @my_rs_vpc.default_route_table()
      sleep(60)
    end
    $default_route_table_href = @default_route_table.href
    $route_igw = to_object(@my_rt_igw)
    $route_igw["fields"]["route_table_href"] = $default_route_table_href
    @my_rt_igw = $route_igw
    provision(@my_rt_igw)
    provision(@server1) 
    $instance_id = @server1.current_instance().resource_uid
    @instance = rs_aws_compute.instances.show(instance_id: $instance_id)
    $instance_dns_name = @instance.privateDnsName
  end
end

define generated_terminate(@server1,@my_vpc,@my_vpc_endpoint,@my_rs_vpc,@my_rs_vpc_endpoint,@my_nat_gateway,@my_nat_ip,@my_igw,@my_subnet,@my_rt_igw) do
  @instance = @server1.current_instance()
  delete(@instance)
  delete(@server1)
  delete(@my_rs_vpc_endpoint)
  delete(@my_vpc_endpoint)
  delete(@my_nat_gateway)
  delete(@my_nat_ip)
  delete(@my_rt_igw)
  delete(@my_igw)
  delete(@my_subnet)
  delete(@my_vpc)
  delete(@my_rs_vpc)
end

define getZones() return $values do
  @clouds = rs_cm.clouds.index(filter: ["cloud_type==amazon"])
  @datacenters = @clouds.datacenters()
  $dc_array = []
  $dcs = []
  foreach @datacenter in @datacenters do
    $zone = @datacenter.name
    $size = size($zone) 
    $datacenter=join(split($zone,"")[0..($size-2)],"")
    $dcs << $datacenter
  end
  $dc_unique = unique($dcs)
  $dc_array = sort($dc_unique)
  $values = $dc_array
end