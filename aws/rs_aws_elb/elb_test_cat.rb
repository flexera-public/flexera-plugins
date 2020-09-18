name 'ELB Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic Load Balancer - Test CAT"
import "plugins/rs_aws_elb"

parameter "lb_name" do
  label "ELB Name"
  description "ELB Name"
  default "myelb-1"
  type "string"
end

output "list_elb" do
  label 'list action'
end

resource "my_elb", type: "rs_aws_elb.elb" do
  name join([$lb_name, last(split(@@deployment.href,'/'))])
  list_lbport "80"
  list_instport "80"
  list_proto "http"
  list_instproto "http"
  az1 "us-east-1a"
  az2 "us-east-1d"
end

operation 'list_elb' do
  definition 'list_elbs'
  output_mappings do{
    $list_elb => $object
  } end
end

define list_elbs() return $object do
  @elbs = rs_aws_elb.elb.empty()
  sub on_error: stop_debugging() do
    call start_debugging()
    @elbs = rs_aws_elb.elb.list()
    call stop_debugging()
  end
  $object = to_object(first(@elbs))
  $object = to_s($object)
end