name 'aws_elb_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic Load Balancer"
package "plugin/rs_aws_elb"
import "sys_log"

plugin "rs_aws_elb" do
  endpoint do
    default_host "elasticloadbalancing.amazonaws.com"
    default_scheme "https"
    path "/"
    query do {
      "Version" => "2012-06-01"
    } end
  end
  
  type "elb" do
    # HREF is set to the correct template in the provision definition due to a lack of usable fields in the response to build the href
    href_templates "/?Action=DescribeLoadBalancers&LoadBalancerNames.member.1={{//LoadBalancerDescriptions/member/LoadBalancerName}}","/?Action=DescribeLoadBalancers&LoadBalancerNames.member.1={{//CreateLoadBalancerResult/DNSName}}", "/?Action=DescribeLoadBalancers&LoadBalancerNames.member.1={{/LoadBalancerName}}"
    provision 'provision_elb'
    delete    'delete_elb'

    field "name" do
      alias_for "LoadBalancerName"
      type      "string"
      location  "query"
      required true
    end

    field "az1" do
      alias_for "AvailabilityZones.member.1"
      type      "string"
      location  "query"
    end

    field "az2" do
      alias_for "AvailabilityZones.member.2"
      type      "string"
      location  "query"
    end

    field "az3" do
      alias_for "AvailabilityZones.member.3"
      type      "string"
      location  "query"
    end

    field "list_lbport" do
      alias_for "Listeners.member.1.LoadBalancerPort"
      type      "string"
      location  "query"
    end

    field "list_instport" do
      alias_for "Listeners.member.1.InstancePort"
      type      "string"
      location  "query"
    end

    field "list_proto" do
      alias_for "Listeners.member.1.Protocol"
      type      "string"
      location  "query"
    end

    field "list_instproto" do
      alias_for "Listeners.member.1.InstanceProtocol"
      type      "string"
      location  "query"
    end

    field "security_group1" do
      alias_for "SecurityGroups.member.1"
      type "string"
      location "query"
    end

    field "security_group2" do
      alias_for "SecurityGroups.member.2"
      type "string"
      location "query"
    end

    field "security_group3" do
      alias_for "SecurityGroups.member.3"
      type "string"
      location "query"
    end

    field "subnet1" do
      alias_for "Subnets.member.1"
      type "string"
      location "query"
    end

    field "subnet2" do
      alias_for "Subnets.member.2"
      type "string"
      location "query"
    end

    field "subnet3" do
      alias_for "Subnets.member.3"
      type "string"
      location "query"
    end

    output 'LoadBalancerName' do
      body_path '//LoadBalancerDescriptions/member/LoadBalancerName'
      type "simple_element"
    end

    output 'DNSName' do
      body_path '//LoadBalancerDescriptions/member/DNSName'
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateLoadBalancer"
    end
    
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteLoadBalancer&LoadBalancerName=$LoadBalancerName"
    end
 
    action "get" do
      verb "POST"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeLoadBalancers"
      output_path "//LoadBalancerDescriptions/member"
    end

    action "register_instance" do
      verb "POST"
      path "/?Action=RegisterInstancesWithLoadBalancer/&LoadBalancerName=$LoadBalancerName"

      field "instance" do
        alias_for "Instances.member.1.InstanceId"
        location "query"
      end
    end
    
    action "deregister_instance" do
      verb "POST"
      path "/?Action=DeregisterInstancesFromLoadBalancer/&LoadBalancerName=$LoadBalancerName"

      field "instance" do
        alias_for "Instances.member.1.InstanceId"
        location "query"
      end
    end
  end
end

resource_pool "elb_pool" do
  plugin $rs_aws_elb
  auth "key", type: "aws" do
    version     4
    service    'elasticloadbalancing'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

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
  name $lb_name
  list_lbport "80"
  list_instport "80"
  list_proto "http"
  list_instproto "http"
  #subnet1 "subnet-7c295240"
  #security_group1 "sg-a9b9e8d6"
  az1 "us-east-1a"
  az2 "us-east-1d"
  description "a simple elb"
end

operation 'list_elb' do
  definition 'list_elbs'
  output_mappings do{
    $list_elb => $object
  } end
end

define provision_elb(@declaration) return @elb do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    # call sys_log.set_task_target(@@deployment)
    # call sys_log.summary("ELB Object")
    # call sys_log.detail($fields)
    
    # call sys_log.set_task_target(@@deployment)
    # call sys_log.summary("Create ELB")
    # call start_debugging()
    @elb = rs_aws_elb.elb.create($fields)
   #  call stop_debugging()

   # call sys_log.set_task_target(@@deployment)
   # call sys_log.summary("ELB Object")
    $elb = to_object(@elb)
   # call sys_log.detail(join(["Original: ",to_object(@elb)]))
    $elb["hrefs"][0] = join(["?Action=DescribeLoadBalancers&LoadBalancerNames.member.1=",$name])
    @elb = $elb
   # call sys_log.detail(join(["Modified: ",to_object(@elb)]))
    
   # call sys_log.set_task_target(@@deployment)
   # call sys_log.summary("Get ELB")
   # call start_debugging()
    @elb = @elb.get()
   # call stop_debugging()
   # call sys_log.detail(join(["After Get: ",to_object(@elb)]))
  end
end

define list_elbs() return $object do
#  call sys_log.set_task_target(@@deployment)
#  call sys_log.summary("List ELB")
#  call start_debugging()
  @elbs = rs_aws_elb.elb.list()
#  call stop_debugging()
  $object = to_object(first(@elbs))
  $object = to_s($object)
end

define delete_elb(@elb) do
  sub on_error: stop_debugging() do
#    call sys_log.set_task_target(@@deployment)
#    call sys_log.summary("Destroy ELB")
#    call sys_log.detail(to_object(@elb))
#    call start_debugging()
    @elb.destroy()
#    call stop_debugging()
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
