name 'aws_emr_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - EMR"
long_description "Version: 1.0"
package "plugins/rs_aws_emr"
import "sys_log"
#https://docs.aws.amazon.com/emr/latest/APIReference/API_Operations.html

#don't destroy once finished with steps.
#https://docs.aws.amazon.com/emr/latest/APIReference/API_JobFlowInstancesConfig.html

#LogUri api bucket for emr cluster logs

plugin "rs_aws_emr" do
  endpoint do
    default_scheme "https"
  end

  type "clusters" do
    href_templates "/DescribeCluster/{{cluster.name}}"
    provision "provision_cluster"
    delete    "delete_resource"

    field "x_amz_target" do 
      alias_for "X-Amz-Target"
      location "header"
      type "string"
    end

    field "name" do
      alias_for "Name"
      type "string"
      required true
    end

    field "additional_info" do
      alias_for "AdditionalInfo"
      type "string"
    end

    field "ami_version" do
      alias_for "AmiVersion"
      type "string"
    end

    field "applications" do
      alias_for "Applications"
      type "array"
    end

    field "auto_scaling_role" do
      alias_for "AutoScalingRole"
      type "string"
    end

    field "bootstrap_actions" do
      alias_for "BootstrapActions"
      type "array"
    end

    field "configurations" do
      alias_for "Configurations"
      type "array"
    end

    field "custom_ami_id" do
      alias_for "CustomAmiId"
      type "string"
    end
 
    field "ebs_root_volume_size" do
      alias_for "EbsRootVolumeSize"
      type "string"
    end

    field "instances" do
      alias_for "Instances"
      type "composite"
    end

    field "job_flow_role" do
      alias_for "JobFlowRole"
      type "string"
    end

    field "kerberos_attributes" do
      alias_for "KerberosAttributes"
      type "composite"
    end

    field "log_uri" do
      alias_for "LogUri"
      type "string"
    end

    field "new_supported_products" do
      alias_for "NewSupportedProducts"
      type "array"
    end

    field "release_label" do
      alias_for "ReleaseLabel"
      type "string"
    end

    field "repo_upgrade_on_boot" do
      alias_for "RepoUpgradeOnBoot"
      type "string"
    end

    field "scale_down_behavior" do
      alias_for "ScaleDownBehavior"
      type "string"
    end

    field "security_configuration" do
      alias_for "SecurityConfiguration"
      type "string"
    end

    field "service_role" do
      alias_for "ServiceRole"
      type "string"
    end

    field "steps" do
      alias_for "Steps"
      type "array"
    end

    field "supported_products" do
      alias_for "SupportedProducts"
      type "array"
    end

    field "tags" do
      alias_for "Tags"
      type "array"
    end

    field "visible_to_all_users" do
      alias_for "VisibleToAllUsers"
      type "boolean"
    end

    action "create" do
      verb "POST"
      path "/"
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

    output "JobFlowId"
  end
  type "job_flow" do
    href_templates "/DescribeCluster/{{cluster.name}}"
    provision "no_operation"
    delete    "no_operation"
    
    field "created_after" do
      alias_for "CreatedAfter"
      type "string"
    end

    field "created_before" do
      alias_for "CreatedBefore"
      type "string"
    end

    field "job_flow_ids" do
      alias_for "JobFlowIds"
      type "array"
    end

    field "job_flow_states" do
      alias_for "JobFlowStates"
      type "array"
    end

    field "x_amz_target" do 
      alias_for "X-Amz-Target"
      location "header"
      type "string"
    end

    action "show" do
      verb "post"
      path "/clusters"
      output_path "clusters[]"
    end
  end
end

resource_pool "rs_aws_emr" do
  plugin $rs_aws_emr
  host "elasticmapreduce.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'emr'
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
    @cluster = rs_aws_emr.$type.create($fields)
    @operation = rs_aws_emr.job_flow.show(x_amz_target: 'ElasticMapReduce.DescribeJobFlows',job_flow_ids: [ @cluster.JobFlowId ])
    call sys_log.detail(to_object(@operation))
    sub timeout: 20m, on_timeout: skip do
      #Valid Values: STARTING | BOOTSTRAPPING | RUNNING | WAITING | TERMINATING | TERMINATED | TERMINATED_WITH_ERRORS
      sleep_until(@operation.status =~ "^(ACTIVE|DELETING|FAILED)")
    end
    if @operation.status != "ACTIVE"
      @operation.destroy()
      raise "Failed to provision EMR Cluster"
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
