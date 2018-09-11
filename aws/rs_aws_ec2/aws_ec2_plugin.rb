name 'aws_ec2_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - EC2 Plugin"
long_description "Version 1.4"
package "plugin/rs_aws_compute"
import "sys_log"

plugin "rs_aws_compute" do
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

    action "show" do
      path "/?Action=DescribeVpcs"
      verb "POST"
      output_path "//DescribeVpcsResponse/vpcSet/item"
      field "vpcId" do
        alias_for "VpcId.1"
        location "query"
      end
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcs"
      output_path "//DescribeVpcsResponse/vpcSet/item"
    end

    action "routeTables" do
      type "route_table"
      verb "POST"
      path "/?Action=DescribeRouteTables&Filter.1.Name=vpc-id&Filter.1.Value=$vpcId"
    end

    action "enablevpcclassiclink" do
      verb "POST"
      path "/?Action=EnableVpcClassicLink&VpcId=$vpcId"
    end

    action "disablevpcclassiclink" do
      verb "POST"
      path "/?Action=DisableVpcClassicLink&VpcId=$vpcId"
    end

    action "enablevpcclassiclinkdnssupport" do
      verb "POST"
      path "/?Action=EnableVpcClassicLinkDnsSupport&VpcId=$vpcId"
    end

    action "disablevpcclassiclinkdnssupport" do
      verb "POST"
      path "/?Action=DisableVpcClassicLinkDnsSupport&VpcId=$vpcId"
    end

    action "create_tag" do
      path "/?Action=CreateTags&ResourceId.1=$vpcId"
      verb "POST"
      field "tag_1_key" do
        alias_for "Tag.1.Key"
        location "query"
      end

      field "tag_1_value" do
        alias_for "Tag.1.Value"
        location "query"
      end
    end

    action "delete_tag" do
      path "/?Action=CreateTags&ResourceId.1=$vpcId"
      verb "POST"
      field "tag_1_key" do
        alias_for "Tag.1.Key"
        location "query"
      end
    end
  end

  type "endpoint" do
    href_templates "/?Action=DescribeVpcEndpoints&VpcEndpointId.1={{//CreateVpcEndpointResponse/vpcEndpoint/vpcEndpointId}}","/?Action=DescribeVpcEndpoints&VpcEndpointId.1={{//DescribeVpcEndpointsResponse/vpcEndpointSet/item/vpcEndpointId}}"
    #href_templates "/?Action=DescribeVpcEndpoints?Filter.1.Name=vpc-endpoint-id&Filter.1.Value={{//CreateVpcEndpointResponse/vpcEndpoint/vpcEndpointId}}"
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

    field "vpc_endpoint_type" do
      alias_for "VpcEndpointType"
      type "string"
      location "query"
    end

    field "private_dns_enabled" do
      alias_for "PrivateDnsEnabled"
      type "string"
      location "query"
    end

    field "security_group_id_1" do
      alias_for "SecurityGroupId.1"
      type "string"
      location "query"
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
      path "/?Action=DeleteVpcEndpoints&VpcEndpointId.1=$vpcEndpointId"
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

  type "route_table" do
    href_templates "/?Action=DescribeRouteTables&RouteTableId.1={{//CreateRouteTableResponse/routeTable/routeTableId}}","/?Action=DescribeRouteTables&RouteTableId.1={{//DescribeRouteTablesResponse/routeTableSet/item/routeTableId}}"
    provision 'provision_route_table'
    delete    'delete_route_table'

    field "vpc_id" do
      alias_for "VpcId"
      type      "string"
      location  "query"
    end
    
    output "routeTableId" do
      type "simple_element"
    end

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "routeSet" do
      type "array"
    end

    output "associationSet" do
      type "simple_element"
    end

    output "tagSet" do
      type "simple_element"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateRouteTable"
      output_path "//CreateRouteTableResponse/routeTable"
    end
    
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteRouteTables&RouteTableId.1=$routeTableId"
    end
 
    action "get" do
      verb "POST"
      output_path "//DescribeRouteTablesResponse/routeTableSet/item"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeVpcEndpoints"
      output_path "//DescribeRouteTablesResponse/routeTableSet/item"
    end
  end

  type "nat_gateway" do
    href_templates "/?Action=DescribeNatGateways&NatGatewayId.1={{//CreateNatGatewayResponse/natGateway/natGatewayId}}","/?Action=DescribeNatGateways&NatGatewayId.1={{//DescribeNatGatewaysResponse/natGatewaySet/item/natGatewayId}}"
    provision 'provision_nat_gateway'
    delete    'delete_nat_gateway'

    field "allocation_id" do
      alias_for "AllocationId"
      type      "string"
      location  "query"
    end

    field "subnet_id" do
      alias_for "SubnetId"
      type      "string"
      location  "query"
    end

    output "natGatewayId" do
      type "simple_element"
    end

    output "subnetId" do
      type "simple_element"
    end

    output "vpcId" do
      type "simple_element"
    end

    output "state" do
      type "simple_element"
    end

    output "natGatewayAddressSet" do
      type "array"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateNatGateway"
      output_path "//CreateNatGatewayResponse/natGateway"
    end
    
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteNatGateway&NatGatewayId=$natGatewayId"
    end
 
    action "get" do
      verb "POST"
      output_path "//DescribeNatGatewaysResponse/natGatewaySet/item"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeNatGateways"
      output_path "//DescribeNatGatewaysResponse/natGatewaySet/item"
    end
  end

  type "addresses" do
    href_templates "/?Action=DescribeAddresses&AllocationId.1={{//DescribeAddressesResponse/addressesSet/item/allocationId}}"
    provision 'no_operation'
    delete    'no_operation'

    field "allocation_id_1" do
      alias_for "AllocationId.1"
      type "string"
      location "query"
    end

    field "public_ip_1" do
      alias_for "PublicIp.1"
      type "string"
      location "query"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeAddresses"
      output_path "//DescribeAddressesResponse/addressesSet/item"
    end

    action "show" do
      verb "POST"
      path "/?Action=DescribeAddresses"
      output_path "//DescribeAddressesResponse/addressesSet/item"
      field "allocation_id_1" do
        alias_for "AllocationId.1"
        location "query"
      end

      field "public_ip_1" do
        alias_for "PublicIp.1"
        location "query"
      end
    end
    action "list" do
      verb "POST"
      path "/?Action=DescribeAddresses"
      output_path "//DescribeAddressesResponse/addressesSet/item"
    end

    output "publicIP" do
      type "simple_element"
    end

    output "domain" do
      type "simple_element"
    end

    output "allocationId" do
      type "simple_element"
    end
  end

  type "tags" do
    href_templates "/?Action=DescribeTags&Filter.1.Name=key&Filter.1.Value={{//DescribeTagsResponse/tagSet/item/key}}&Filter.2.Name=value&Filter.2.Value={{//DescribeTagsResponse/tagSet/item/value}}&Filter.3.Name=resource-id&Filter.3.Value.1={{//DescribeTagsResponse/tagSet/item/resourceId}}","/?Action=DescribeTags&Filter.1.Name=key&Filter.1.Value=$tag_1_key&Filter.2.Name=value&Filter.2.Value=$tag_1_value&Filter.3.Name=resource-id&Filter.3.Value.1=$resource_id_1"
    provision 'provision_tags'
    delete    'delete_tags'

    field "resource_id_1" do
      alias_for "ResourceId.1"
      type "string"
      location "query"
    end

    field "tag_1_key" do
      alias_for "Tag.1.Key"
      type "string"
      location "query"
    end

    field "tag_1_value" do
      alias_for "Tag.1.Value"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateTags"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeTags"
      output_path "//DescribeTagsResponse/tagSet/item"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteTags"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeTags"
      output_path "//DescribeTagsResponse/tagSet/item"
    end

    output "resourceId" do
      type "simple_element"
    end

    output "resourceType" do
      type "simple_element"
    end

    output "key" do
      type "simple_element"
    end

    output "value" do
      type "simple_element"
    end
  end

  type "volume" do
    href_templates "/?Action=DescribeVolumes&VolumeId.1={{//CreateVolumeResponse/volumeId}}","/?Action=DescribeVolumes&VolumeId.1={{//DescribeVolumesResponse/volumeSet/item/volumeId}}"
    provision 'provision_volume'
    delete    'delete_volume'

    field "availability_zone" do
      alias_for "AvailabilityZone"
      type "string"
      location "query"
    end

    field "encrypted" do
      alias_for "Encrypted"
      type "string"
      location "query"
    end

    field "iops" do
      alias_for "Iops"
      type "string"
      location "query"
    end

    field "kms_key_id" do
      alias_for "KmsKeyId"
      type "string"
      location "query"
    end

    field "size" do
      alias_for "Size"
      type "string"
      location "query"
    end

    field "snapshot_id" do
      alias_for "SnapshotId"
      type "string"
      location "query"
    end

    field "volume_type" do
      alias_for "VolumeType"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateVolume"
      output_path "//CreateVolumeResponse"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeVolume"
      output_path "//DescribeVolumesResponse/volumeSet/item"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteVolume&VolumeId=$volumeId"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVolume"
      output_path "//DescribeVolumesResponse/volumeSet/item"
    end

    output "volumeId" do
      type "simple_element"
    end

    output "size" do
      type "simple_element"
    end

    output "availabilityZone" do
      type "simple_element"
    end

    output "status" do
      type "simple_element"
    end

    output "createTime" do
      type "simple_element"
    end

    output "attachmentSet" do
      type "complex_element"
    end

    output "volumeType" do
      type "simple_element"
    end

    output "encrypted" do
      type "simple_element"
    end
  end

  type "volume_modification" do
    href_templates "/?Action=DescribeVolumesModifications&VolumeId.1={{//DescribeVolumesModificationsResponse/volumeModificationSet/item/volumeId}}"
    provision 'provision_volume_modification'
    delete    'no_operation'

    field "volume_id" do
      alias_for "VolumeId"
      type "string"
      location "query"
    end

    field "iops" do
      alias_for "Iops"
      type "string"
      location "query"
    end

    field "size" do
      alias_for "Size"
      type "string"
      location "query"
    end

    field "volume_type" do
      alias_for "VolumeType"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=ModifyVolume"
      output_path "//ModifyVolumeResponse/volumeModification"
    end

    action "get" do
      verb "POST"
      path "/?Action=DescribeVolumesModifications"
      output_path "//DescribeVolumesModificationsResponse/volumeModificationSet/item"
    end

    action "list" do
      verb "POST"
      path "/?Action=DescribeVolumesModifications"
      output_path "//DescribeVolumesModificationsResponse/volumeModificationSet/item"
    end

    output "volumeId" do
      type "simple_element"
    end

    output "targetIops" do
      type "simple_element"
    end

    output "originalIops" do
      type "simple_element"
    end

    output "modificationState" do
      type "simple_element"
    end

    output "targetSize" do
      type "simple_element"
    end

    output "targetVolumeType" do
      type "simple_element"
    end

    output "progress" do
      type "simple_element"
    end

    output "startTime" do
      type "simple_element"
    end

    output "originalSize" do
      type "simple_element"
    end

    output "originalVolumeType" do
      type "simple_element"
    end
  end
end

resource_pool "ec2_pool" do
  plugin $rs_aws_compute
  auth "key", type: "aws" do
    version     4
    service    'ec2'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_vpc(@declaration) return @vpc do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @vpc = rs_aws_compute.vpc.create($fields)
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

define provision_endpoint(@declaration) return @vpcendpoint do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @vpcendpoint = rs_aws_compute.endpoint.create($fields)
    call stop_debugging()
    $vpc = to_object(@vpcendpoint)
    call sys_log.detail(join(["vpcendpoint:", to_s($vpc)]))
    call start_debugging()
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

define provision_route_table(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @resource = rs_aws_compute.route_table.create($fields)
    call stop_debugging()
    $vpc = to_object(@resource)
    call sys_log.detail(join(["vpcendpoint:", to_s($vpc)]))
    call start_debugging()
    $state = @resource.state
    call stop_debugging()
    while $state != "available" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @resource.state
      call stop_debugging()
    end
  end
end

define provision_nat_gateway(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @resource = rs_aws_compute.nat_gateway.create($fields)
    call stop_debugging()
    $vpc = to_object(@resource)
    call sys_log.detail(join(["natgateway:", to_s($vpc)]))
    call start_debugging()
    $state = @resource.state
    call stop_debugging()
    while $state != "available" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @resource.state
      call stop_debugging()
    end
  end
end

define provision_tags(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @resource = rs_aws_compute.tags.create($fields)
    call stop_debugging()
    $vpc = to_object(@resource)
    call sys_log.detail(join(["tags:", to_s($vpc)]))
  end
end

define provision_volume(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @resource = rs_aws_compute.volume.create($fields)
    call stop_debugging()
    $volume = to_object(@resource)
    call sys_log.detail(join(["volume:", to_s($volume)]))
    call start_debugging()
    $state = @resource.status
    call stop_debugging()
    while $state != "available" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @resource.status
      call stop_debugging()
    end
  end
end

define provision_volume_modification(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $name = $fields['name']
    call start_debugging()
    @resource = rs_aws_compute.volume.create($fields)
    call stop_debugging()
    $volume_modification = to_object(@resource)
    call sys_log.detail(join(["volume:", to_s($volume_modification)]))
    call start_debugging()
    $state = @resource.modificationState
    call stop_debugging()
    while $state != "completed" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @resource.modificationState
      call stop_debugging()
    end
  end
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
    sleep(30)
    call stop_debugging()
  end
end

define delete_route_table(@route_table) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @route_table.destroy()
    sleep(30)
    call stop_debugging()
  end
end

define delete_nat_gateway(@nat_gateway) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @nat_gateway.destroy()
    sleep(30)
    $state = @nat_gateway.state
    while $state != "deleted" do
      sleep(10)
      call sys_log.detail(join(["state: ", $state]))
      call start_debugging()
      $state = @nat_gateway.state
      call stop_debugging()
    end
    call stop_debugging()
  end
end

define delete_tags(@tag) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @tag.destroy()
    call stop_debugging()
  end
end

define delete_volume(@volume) do
  sub on_error: stop_debugging() do
    call start_debugging()
    @volume.destroy()
    call stop_debugging()
  end
end

define no_operation(@resource) return @resource do
  @resource=@resource
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
