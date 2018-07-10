name 'aws_eks_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - EKS"
long_description "Version: 1.0"
package "plugins/rs_aws_eks"
import "sys_log"

plugin "rs_aws_eks" do
  endpoint do
    default_scheme "https"
  end

  type "clusters" do
    href_templates "/clusters/{{cluster.name}}"
    provision "provision_cluster"
    delete    "delete_resource"

    field "client_request_token" do
      alias_for "clientRequestToken"
      type "string"
    end

    field "name" do
      type "string"
      required true
    end

    field "resources_vpc_config" do
      alias_for "resourcesVpcConfig"
      type "composite"
      required true
    end

    field "role_arn" do
      alias_for "roleArn"
      type "string"
      required true
    end

    field "version" do
      type "string"
    end

    field "next_token" do
      alias_for "nextToken"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/clusters"
    end

    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    action "get" do
      verb "GET"
      path "$href"
    end

    action "list" do
      verb "GET"
      path "/clusters"

      output_path "clusters[]"
    end

    output_path "cluster"

    output "endpoint","status","createdAt","certificateAuthority","arn","roleArn","clientRequestToken","version","name","resourcesVpcConfig"

  end

end

resource_pool "rs_aws_eks" do
  plugin $rs_aws_eks
  host "eks.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'eks'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define no_operation() do
end

define provision_cluster(@declaration) return @resource do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_aws_eks.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    sub timeout: 20m, on_timeout: skip do
      sleep_until(@operation.status =~ "^(ACTIVE|DELETING|FAILED)")
    end
    if @operation.status != "ACTIVE"
      @operation.destroy()
      raise "Failed to provision EKS Cluster"
    end
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  @declaration.destroy()
  call stop_debugging()
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
