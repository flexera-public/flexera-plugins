name 'aws_iam_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - AWS Identity and Access Management"
long_description "Version: .01"
package "plugins/rs_aws_iam"
import "sys_log"
import "plugin_generics"

plugin "rs_aws_iam" do
  endpoint do
    default_scheme "https"
    default_host "iam.amazonaws.com"
    path "/"
    query do {
      "Version" => "2010-05-08"
    } end
  end

  type "role" do
    href_templates "/?Action=GetRole&RoleName={{//GetRoleResult/Role/RoleName}}"

    provision "provision_role"
    delete    "delete_role"

    field "assume_role_policy_document" do
      alias_for "AssumeRolePolicyDocument"
      location "query"
      type "composite"
      required true
    end
    field "description" do
      location "query"
      type "string"
    end
    field "max_session_duration" do
      alias_for "MaxSessionDuration"
      location "query"
      type "number"
    end
    field "path" do
      location "query"
      type "string"
    end
    field "name" do
      alias_for "RoleName"
      location 'query'
      required true
      type "string"
    end

    output_path "//Role"

    output "RoleName","RoleID"

    action "create" do
      verb "POST"
      path "/?Action=CreateRole"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteRole"
    end

    action "get" do
      verb "POST"
      path "$href?Action=GetRole"
    end
  end
end

resource_pool "iam" do
  plugin $rs_aws_iam
  auth "key", type: "aws" do
    version     4
    service    'iam'
    region     'global'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_role(@declaration) return @role do
  sub on_error: plugin_generics.stop_debugging() do
    call plugin_generics.start_debugging()
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Role")
    $object = to_object(@declaration)
    $fields = $object["fields"]
    call sys_log.detail(to_s($fields))
    @role = rs_aws_iam.role.create($fields)
    sub on_error: skip do
      sleep_until(@role.RoleId != null)
    end
    @role = @role.get()
    call plugin_generics.stop_debugging()
  end
end

define delete_role(@role) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    call plugin_generics.start_debugging()
      @role.destroy()
    call plugin_generics.stop_debugging()
  end
end

define handle_retries($attempts) do
  if $attempts <= 6
    sleep(10*to_n($attempts))
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("error:"+$_error["type"] + ": " + $_error["message"])
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end
