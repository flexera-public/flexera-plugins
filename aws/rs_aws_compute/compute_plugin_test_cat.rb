name 'AWS EC2 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"
import "plugin/aws_compute"

parameter "param_region" do
  like $aws_compute.param_region
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
  default_value @my_volume.id
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

resource "my_vpc", type: "aws_compute.vpc" do
  cidr_block "10.0.0.0/16"
  instance_tenancy "default"
end

resource "my_vpc_tag", type: "aws_compute.tags" do
  resource_id_1 @my_vpc.id
  tag_1_key "Name"
  tag_1_value join([@@deployment.name,"-vpc"])
end

resource "my_vpc_endpoint", type: "aws_compute.endpoint" do
  vpc_id @my_vpc.id
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_rs_vpc_endpoint", type: "aws_compute.endpoint" do
  vpc_id @my_rs_vpc.resource_uid
  service_name "com.amazonaws.us-east-1.s3"
end

resource "my_nat_gateway", type: "aws_compute.nat_gateway" do
  allocation_id "replace-me"
  subnet_id @my_subnet.resource_uid
end

resource "my_volume", type: "aws_compute.volume" do
  availability_zone "us-east-1a"
  size "10"
  volume_type "gp2"
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

define resize_volume($param_region,@my_volume,$new_size) return @my_volume do
  aws_compute.volume_modification.create(volume_id: @my_volume.volumeId, size: $new_size)
end

define snapshot_root_volume($param_region, $param_instance_id, $param_image_name, $param_image_description) return $ami_id do
  call aws_compute.start_debugging()
  $ami_id = 111
  sub on_error: stop_debugging() do
    @instance = aws_compute.instances.show(instance_id: $param_instance_id)
    @image = @instance.create_image(name: $param_image_name, description: $param_description)
    $ami_id = @image.imageId
  end
  call aws_compute.stop_debugging()
end

define deregister_image($param_region,$param_ami_id) do
  call aws_compute.start_debugging()
  sub on_error: stop_debugging() do
    @image = aws_compute.images.show(image_id: $param_ami_id)
    @image.deregister_image()
  end
  call aws_compute.stop_debugging()
end
define handle_retries($attempts) do
  if $attempts <= 10
    sleep(60)
    $_error_behavior = "retry"
  else
    $_error_behavior = "skip"
  end
end

define generated_launch($param_region,@my_vpc,@my_vpc_endpoint,@my_nat_ip,@my_nat_gateway,@my_subnet,@my_igw,@my_volume,@my_vpc_tag,@my_sg,@my_rt_igw) return @my_vpc,@my_vpc_endpoint,@my_nat_ip,@my_nat_gateway,@my_subnet,@my_igw,@my_volume,@my_sg,@my_rt_igw do
  call aws_compute.start_debugging()
  sub on_error: aws_compute.stop_debugging() do
    provision(@my_vpc)
    provision(@my_vpc_tag)
    @route_tables = @my_vpc.routeTables()
    $endpoint = to_object(@my_vpc_endpoint)
    $endpoint["fields"]["route_table_id_1"] = @route_tables.routeTableId
    @my_vpc_endpoint = $endpoint
    provision(@my_vpc_endpoint)
    $subnet = to_object(@my_subnet)
    @my_subnet = $subnet
    provision(@my_subnet)
    provision(@my_igw)
    provision(@my_nat_ip)
    @aws_ip = aws_compute.addresses.show(public_ip_1: @my_nat_ip.address)
    $nat_gateway = to_object(@my_nat_gateway)
    $nat_gateway["fields"]["allocation_id"] = @aws_ip.allocationId
    @my_nat_gateway = $nat_gateway
    provision(@my_nat_gateway)
    provision(@my_volume)
    provision(@my_sg)
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
