name 'aws_elb_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic Load Balancer"
long_description "Version: 1.2"
package "plugins/rs_aws_elb"
import "sys_log"

plugin "rs_aws_elb" do
  endpoint do
    default_scheme "https"
    path "/"
    headers do {
      "content-type" => "application/xml"
    } end
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

    #Non-Create Fields
    field "load_balancer_port" do
      alias_for "LoadBalancerPort"
      location "query"
      type "number"
    end

    field "ssl_certificate_id" do
      alias_for "SSLCertificateId"
      location "query"
      type "string"
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

    action "show" do
      verb "POST"
      path "/?Action=DescribeLoadBalancers"

      field "name" do
        location "query"
        alias_for "LoadBalancerNames.member.1"
      end 
    end 

    action "list" do
      verb "POST"
      path "/?Action=DescribeLoadBalancers"
      output_path "//LoadBalancerDescriptions/member"
    end

    action "register_instance" do
      verb "POST"
      path "/?Action=RegisterInstancesWithLoadBalancer&LoadBalancerName=$LoadBalancerName"

      field "instance" do
        alias_for "Instances.member.1.InstanceId"
        location "query"
      end
    end

    action "deregister_instance" do
      verb "POST"
      path "/?Action=DeregisterInstancesFromLoadBalancer&LoadBalancerName=$LoadBalancerName"

      field "instance" do
        alias_for "Instances.member.1.InstanceId"
        location "query"
      end
    end

    action "set_certificate" do
      verb "POST"
      path "/?Action=SetLoadBalancerListenerSSLCertificate&LoadBalancerName=$LoadBalancerName"

      field "load_balancer_port" do
        alias_for "LoadBalancerPort"
        location "query"
      end

      field "ssl_certificate_id" do
        alias_for "SSLCertificateId"
        location "query"
      end
    end
  end
end

resource_pool "elb_pool" do
  plugin $rs_aws_elb
  host "elasticloadbalancing.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'elasticloadbalancing'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_elb(@declaration) return @elb do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("ELB Object")
    call sys_log.detail($fields)

    call start_debugging()
    @elb = rs_aws_elb.elb.create($fields)
    call stop_debugging()

    @elb = rs_aws_elb.elb.show(name: $name)
    call start_debugging()
    @elb = @elb.get()
    call stop_debugging()
  end
end

define delete_elb(@elb) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @elb.destroy()
    call stop_debugging()
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
