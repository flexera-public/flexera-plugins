name 'aws_mq_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - MQ"
long_description "Version: 1.0"
package "plugins/rs_aws_mq"
import "sys_log"

plugin "rs_aws_mq" do
  endpoint do
    default_scheme "https"
    path "/v1"
  end
  
  type "brokers" do
    href_templates "/brokers/{{brokerId}}","/brokers/{{brokerSummaries[*].brokerId}}"
    provision "provision_broker"
    delete    "delete_resource"

    field "broker_name" do
      alias_for "brokerName"
      type "string"
      required true
    end

    field "auto_minor_version_upgrade" do
      alias_for "autoMinorVersionUpgrade"
      type "boolean"
      required true
    end

    field "configuration" do
      type "composite"
    end

    field "creator_request_id" do
      type "string"
      alias_for "creatorRequestId"
    end

    field "deployment_mode" do
      type "string"
      alias_for "deploymentMode"
      required true
    end

    field "engine_type" do
      type "string"
      alias_for "engineType"
      required true
    end

    field "engine_version" do
      type "string"
      alias_for "engineVersion"
      required true
    end

    field "host_instance_type" do
      type "string"
      alias_for "hostInstanceType"
      required true
    end

    field "maintenance_window_start_time" do
      alias_for "maintenanceWindowStartTime"
      type "composite"
    end

    field "publicly_accessible" do
      alias_for "publiclyAccessible"
      type "boolean"
      required true
    end

    field "security_groups" do
      alias_for "securityGroups"
      type "array"
      required true
    end

    field "subnet_ids" do
      alias_for "subnetIds"
      type "array"
      required true
    end

    field "users" do
      type "composite"
      required true
    end
 
    action "create" do
      verb "POST"
      path "/brokers"
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
      path "/brokers"

      output_path "brokerSummaries[]"
    end

    action "update" do
      verb "PUT"
      path "$href"
    end 

    action "reboot" do
      verb "POST"
      path "/brokers/$brokerId/reboot"
    end 

    link "users" do
      path "$href/users"
      type "users"
    end 
    
    output "brokerArn","brokerId","brokerName","brokerState","engineType","engineVersion","hostInstanceType","publiclyAccessible","autoMinorVersionUpgrade","deploymentMode","subnetIds","securityGroups","maintenanceWindowStartTime","configurations","users","created"
    
    output "consoleURL" do
      body_path "brokerInstances[*].consoleURL"
    end

    output "endpoints" do
      body_path "brokerInstances[*].endpoints"
    end 

  end

  type "configurations" do
    href_templates "/configurations/{{id}}","/configurations/{{configurations[*].id}}"
    provision "provision_configuration"
    delete    "no_operation"

    field "engine_type" do
      alias_for "engineType"
      type "string"
      required true
    end

    field "engine_version" do
      alias_for "engineVersion"
      type "string"
      required true
    end

    field "name" do
      type "string"
      required true
    end

    field "description" do
      type "string"
    end 

    field "data" do
      type "string"
      #base-64 encoded string
    end 

    action "create" do
      verb "POST"
      path "/configurations"
    end
    
    action "get" do
      verb "GET"
      path "$href"
    end
    
    action "list" do
      verb "GET"
      path "/configurations"

      output_path "configurations[]"
    end

    action "update" do
      verb "PUT"
      path "$href"
    end 

    link "configuration_revisions" do
      path "$href/revisions"
      type "configuration_revisions"
    end 
    
    output "id","name","arn","engineType","engineVersion","description","created","latestRevision"

  end

  type "configuration_revisions" do
    href_templates "/configurations/{{configurationId}}/revisions/{{revision}}","/configurations/{{configurationId}}/revisions/{{revisions[*].revision}}"
    provision "no_operation"
    delete    "no_operation"
    
    field "configuration_id" do
      type "string"
      location "path"
    end 

    field "revision" do
      type "string"
      location "path"
    end 

    action "get" do
      verb "GET"
      path "$href"
    end

    action "show" do
      verb "GET"
      path "/configurations/$configuration_id/revisions/$revision"
    end
    
    action "list" do
      verb "GET"
      path "/configurations/$configuration_id/revisions"

      output_path "revisions[]"
    end

    link "configuration" do
      path "/configurations/$configurationId"
      type "configurations"
    end 
    
    output "revision","description","created","configurationId","data"

  end

  type "users" do
    href_templates "/brokers/{{brokerId}}/users/{{username}}","/configurations/{{configurations[*].id}}"
    provision "provision_user"
    delete    "delete_resource"

    field "password" do
      type "string"
      required true
    end

    field "console_access" do
      alias_for "consoleAccess"
      type "boolean"
    end

    field "groups" do
      type "array"
    end

    field "username" do
      type "string"
      location "path"
    end 

    field "broker_id" do
      type "string"
      location "path"
    end 

    action "create" do
      verb "POST"
      path "/brokers/$broker_id/users/$username"
    end
    
    action "get" do
      verb "GET"
      path "$href"
    end

    action "show" do
      verb "GET"
      path "/brokers/$broker_id/users/$username"
    end
    
    action "list" do
      verb "GET"
      path "/brokers/$broker_id/users"

      output_path "users[]"
    end

    action "update" do
      verb "PUT"
      path "$href"
    end 

    action "destroy" do
      verb "DELETE"
      path "$href"
    end 

    link "broker" do
      path "/brokers/$brokerId"
      type "brokers"
    end 
    
    output "brokerId","username","consoleAccess","groups","pending"
  end


end

resource_pool "rs_aws_mq" do
  plugin $rs_aws_mq
  host "mq.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'mq'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define no_operation() do
end 

define provision_broker(@declaration) return @resource do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_aws_mq.brokers.create($fields)
    call sys_log.detail(to_object(@operation))
    sub timeout: 20m, on_timeout: skip do
      sleep_until @operation.brokerState == "RUNNING"
    end
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_configuration(@declaration) return @resource do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_aws_mq.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define provision_user(@declaration) return @resource do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    $username = $fields["username"]
    $broker_id = $fields["broker_id"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_aws_mq.users.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show(username: $username, broker_id: $broker_id)
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
