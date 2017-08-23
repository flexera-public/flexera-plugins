name 'aws_vpc_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic Load Balancer"
package "plugin/rs_aws_vpc"
import "sys_log"

plugin "rs_aws_vpc" do
  endpoint do
    default_host "ec2.amazonaws.com"
    default_scheme "https"
    query do {
      "Version" => "2016-11-15"
    } end
  end
  
  type "vpc" do
    # HREF is set to the correct template in the provision definition due to a lack of usable fields in the response to build the href
    href_templates "/?Action=DescribeVpcs&VpcId.1={{//CreateVpcResponse/vpc/vpcId}}","/?DescribeVpcs&VpcId.1={{//DescribeVpcsResponse/vpcSet/item/vpcId}}"
    provision 'provision_vpc'
    delete    'delete_vpc'

    field "amazon_provided_ipv6_cidr_block" do
      alias_for "AmazonProvidedIpv6CidrBlock"
      type      "string"
      location  "query"
    end

    field "cidr_block" do
      alias_for "CidrBlock"
      type      "string"
      location  "query"
    end

    field "instance_tenancy" do
      alias_for "InstanceTenancy"
      type      "string"
      location  "query"
    end
    
    output "vpc"

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "cidrBlock" do
      type "simple_element"
    end

    output "ipv6CidrBlockAssociationSet" do
      type "simple_element"
    end

    output "dhcpOptionsId" do
      type "simple_element"
    end

    output "tagSet" do
      type "simple_element"
    end

    output "instanceTenancy" do
      type "simple_element"
    end

    output "isDefault" do
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateVpc"
      output_path "//CreateVpcResponse/vpc"
    end
    
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteVpc&VpcId=$vpcId"
    end
 
    action "get" do
      verb "POST"
      output_path "//DescribeVpcsResponse/vpcSet/item"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcs"
      output_path "//DescribeVpcsResponse/vpcSet/item"
    end
  end

  type "endpoint" do
    href_templates "/?Action=DescribeVpcEndpoints?VpcEndpointIds.1={{//CreateVpcEndpointResponse/vpcEndpoint/vpcEndpointId}}","/?Action=DescribeVpcEndpoints?VpcEndpointIds.1={{//DescribeVpcEndpointsResponse/vpcEndpointSet/item/vpcEndpointId}}"
    #href_templates "/?Action=DescribeVpcEndpoints?Filter.1=Name=vpc-endpoint-id,Value={{//CreateVpcEndpointResponse/vpcEndpoint/vpcEndpointId}}"
    provision 'provision_endpoint'
    delete    'delete_endpoint'

    field "vpc_id" do
      alias_for "VpcId"
      type      "string"
      location  "query"
    end

    field "service_name" do
      alias_for "ServiceName"
      type      "string"
      location  "query"
    end

    field "route_table_id_1" do
      alias_for "RouteTableId.1"
      type      "string"
      location  "query"
    end
    
    output "vpcEndpointId" do
      type "simple_element"
    end

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "routeTableIdSet" do
      type "array"
    end

    output "creationTimestamp" do
      type "simple_element"
    end

    output "policyDocument" do
      type "simple_element"
    end

    output "serviceName" do
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateVpcEndpoint"
      output_path "//CreateVpcEndpointResponse/vpcEndpoint"
    end
    
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteVpcEndpoint&VpcEndpointId.1=$vpcEndpointId"
    end
 
    action "get" do
      verb "POST"
      output_path "//DescribeVpcEndpointsResponse/vpcEndpointSet/item"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcEndpoints"
      output_path "//DescribeVpcEndpointsResponse/vpcEndpointSet/item"
    end
  end
end

resource_pool "vpc_pool" do
  plugin $rs_aws_vpc
  auth "key", type: "aws" do
    version     4
    service    'ec2'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

parameter "lb_name" do
  label "ELB Name"
  description "ELB Name"
  default "myvpc-1"
  type "string"
end

output "list_vpc" do
  label 'list action'
end

resource "my_vpc", type: "rs_aws_vpc.vpc" do
  cidr_block "10.0.0.0/16"
  instance_tenancy "default"
end

resource "my_vpc_endpont", type: "rs_aws_vpc.endpoint" do
  vpc_id @my_vpc.vpcId
  service_name "com.amazonaws.us-east-1.s3"
end

operation 'list_vpc' do
  definition 'list_vpcs'
  output_mappings do{
    $list_vpc => $object
  } end
end

define provision_vpc(@declaration) return @vpc do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @vpc = rs_aws_vpc.vpc.create($fields)
    call stop_debugging()
    $vpc = to_object(@vpc)
    call sys_log.detail(join(["vpc:", to_s($vpc)]))
    #$vpc["hrefs"][0] = join(["?Action=DescribeLoadBalancers&LoadBalancerNames.member.1=",$name])
    #@vpc = $vpc
    $state = @vpc.state
    while $state != "available" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @vpc.state
      call stop_debugging()
    end
  end
end

define provision_endpoint(@declaration) return @vpc do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @vpcendpoint = rs_aws_vpc.endpoint.create($fields)
    call stop_debugging()
    $vpc = to_object(@vpcendpoint)
    call sys_log.detail(join(["vpcendpoint:", to_s($vpc)]))
    call start_debugging()
    @vpcendpoint.get()
    call sys_log.detail(join(["e2:", to_s(to_object(@vpcendpoint))]))
    $state = @vpcendpoint.state
    call stop_debugging()
    while $state != "available" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @vpcendpoint.state
      call stop_debugging()
    end
  end
end

define list_vpcs() return $object do

#  call start_debugging()
  @vpcs = rs_aws_vpc.vpc.list()
#  call stop_debugging()
  $object = to_object(first(@vpcs))
  $object = to_s($object)
end

define delete_vpc(@vpc) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @vpc.destroy()
    call stop_debugging()
  end
end

define delete_endpoint(@endpoint) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @endpoint.destroy()
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
