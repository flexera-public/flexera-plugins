name 'AWS EC2 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"
import "plugin/aws_compute"

parameter "param_region" do
  like $aws_compute.param_region
end


resource "instance", type: "aws_compute.instances" do
  image_id "ami-0b898040803850657"
  instance_type "t2.large"
  subnet_id "subnet-e7eb98ac"
  key_name "Kube"
  min_count "1"
  max_count "1"
  placement_availability_zone "us-east-1b"
  placement_tenancy "default"
  tag_specification_1_resource_type "instance"
  tag_specification_1_tag_1_key "Name"
  tag_specification_1_tag_1_value @@deployment.name
end

operation "launch" do
  definition "generated_launch"
end

operation "terminate" do
  definition "generated_terminate"
end


define generated_launch($param_region, @instance) return @instance do
  call aws_compute.start_debugging()
  sub on_error: aws_compute.stop_debugging() do
    provision(@instance)
  end
end

define generated_terminate(@instance) do
  delete(@instance)
end
