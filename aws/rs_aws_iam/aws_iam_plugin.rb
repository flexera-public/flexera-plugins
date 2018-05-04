name 'aws_iam_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - AWS Identity and Access Management"
long_description "Version: .01"
package "plugins/rs_aws_iam"
import "sys_log"
import "plugin_generics"

resource_pool "iam" do
  plugin $rs_aws_iam
  auth "key", type: "aws" do
    version     4
    service    'iam'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

plugin "rs_aws_iam" do
  endpoint do
    default_scheme "https"
    default_host "iam.amazonaws.com"
    headers do {
      "content-type" => "application/xml"
    } end
    path "/"
    query do {
      "Version" => "2010-05-08"
    } end
  end

  type "role" do
    href_templates "/?Action=GetRole&RoleName={{//CreateRoleResult/Role/RoleName}}","/?Action=GetRole&RoleName={{//GetRoleResult/Role/RoleName}}"

    provision "provision_role"
    delete    "delete_role"

    field "assume_role_policy_document" do
      alias_for "AssumeRolePolicyDocument"
      location "query"
      type "string"
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
    field "policies" do
      type "array"
      required false
    end

    output_path "//Role"

    output "RoleName","RoleId"

    action "create" do
      verb "POST"
      path "?Action=CreateRole"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteRole"
    end

    action "get" do
      verb "POST"
      path "$href?Action=GetRole"
    end
    action "attach_policy" do
      verb "POST"
      path "$href?Action=AttachRolePolicy&RoleName=$RoleName"
      field "policy_arn" do
        alias_for "PolicyArn"
        location "query"
      end
    end
    action "detach_policy" do
      verb "POST"
      path "$href?Action=DetachRolePolicy&RoleName=$RoleName"
      field "policy_arn" do
        alias_for "PolicyArn"
        location "query"
      end
    end
    action "attached_polices" do
      verb "POST"
      path "$href?Action=ListAttachedRolePolicies&RoleName=$RoleName"
      output_path "//ListAttachedRolePoliciesResult/AttachedPolicies/member"
      type "policy"
    end
  end

  type "policy" do
    href_templates "/?Action=GetPolicy&PolicyArn={{//CreatePolicyResult/Policy/Arn}}","/?Action=GetPolicy&PolicyArn={{//GetPolicyResult/Policy/Arn}}","/?Action=GetPolicy&PolicyArn={{//AttachedPolicies/member/PolicyArn}}"

    provision "provision_policy"
    delete    "delete_policy"

    field "policy_document" do
      alias_for "PolicyDocument"
      location "query"
      type "string"
      required true
    end
    field "description" do
      location "query"
      type "string"
    end
    field "path" do
      location "query"
      type "string"
    end
    field "name" do
      alias_for "PolicyName"
      location 'query'
      required true
      type "string"
    end

    output_path "//Policy"

    output "PolicyName","PolicyId","Arn","PolicyArn"

    action "create" do
      verb "POST"
      path "?Action=CreatePolicy"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeletePolicy"
    end

    action "get" do
      verb "POST"
      path "$href?Action=GetPolicy"
    end
  end

  type "instance_profile" do
    href_templates "/?Action=GetInstanceProfile&InstanceProfileName={{//CreateInstanceProfileResult/InstanceProfile/InstanceProfileName}}","/?Action=GetInstanceProfile&InstanceProfileName={{//GetInstanceProfileResult/InstanceProfile/InstanceProfileName}}"

    provision "provision_instance_profile"
    delete    "delete_instance_profile"

    field "path" do
      location "query"
      type "string"
    end
    field "name" do
      alias_for "InstanceProfileName"
      location 'query'
      required true
      type "string"
    end
    field "role_name" do
      required false
      type "string"
    end

    output_path "//InstanceProfile"

    output "InstanceProfileName","InstanceProfileId","Arn"

    output "RoleName" do
      body_path "Roles/member/RoleName"
      type "string"
    end

    action "create" do
      verb "POST"
      path "?Action=CreateInstanceProfile"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteInstanceProfile"
    end

    action "get" do
      verb "POST"
      path "$href?Action=GetInstanceProfile"
    end

    action "add_role" do
      verb "POST"
      path "$href?Action=AddRoleToInstanceProfile"

      field "role_name" do
        alias_for "RoleName"
        location "query"
      end
      field "instance_profile" do
        alias_for "InstanceProfileName"
        location "query"
      end
    end

    action "remove_role" do
      verb "POST"
      path "$href?Action=RemoveRoleFromInstanceProfile"
      field "role_name" do
        alias_for "RoleName"
        location "query"
      end
      field "instance_profile" do
        alias_for "InstanceProfileName"
        location "query"
      end
    end
  end
end

define provision_role(@declaration) return @role do
  sub on_error: plugin_generics.stop_debugging() do
    call plugin_generics.start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    # create new fields object to conditionally add non-required fields
    $new_fields = {}
    $new_fields["name"]=$fields["name"]
    $new_fields["assume_role_policy_document"]=$fields["assume_role_policy_document"]
    if $fields["path"]
      $new_fields["path"]=$fields["path"]
    end
    if $fields["max_session_duration"]
      $new_fields["max_session_duration"]=$fields["max_session_duration"]
    end
    if $fields['description']
      $new_fields["description"]=$fields["description"]
    end
    @role = rs_aws_iam.role.create($new_fields)
    sub on_error: skip do
      sleep_until(@role.RoleId != null)
    end
    @role = @role.get()
    foreach $policy in $fields['policies'] do
      @role.attach_policy({
        policy_arn: $policy
        })
    end
    call plugin_generics.stop_debugging()
  end
end

define delete_role(@role) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    call plugin_generics.start_debugging()
    if @role
      foreach @policy in @role.attached_polices() do
        @role.detach_policy({
          policy_arn: @policy.Arn
        })
      end
      @role.destroy()
    end
    call plugin_generics.stop_debugging()
  end
end

define provision_policy(@declaration) return @policy do
  sub on_error: plugin_generics.stop_debugging() do
    call plugin_generics.start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    @policy = rs_aws_iam.policy.create($fields)
    sub on_error: skip do
      sleep_until(@policy.PolicyArn != null)
    end
    @policy = @policy.get()
    call plugin_generics.stop_debugging()
  end
end

define delete_policy(@policy) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    call plugin_generics.start_debugging()
    @policy.destroy()
    call plugin_generics.stop_debugging()
  end
end

define provision_instance_profile(@declaration) return @instance_profile do
  sub on_error: plugin_generics.stop_debugging() do
    call plugin_generics.start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    # specify each field to exclude the roles field.
    @instance_profile = rs_aws_iam.instance_profile.create({
      name: $fields["name"],
      path: $fields["path"]
    })
    # add roles to the instance profile
    if $fields["role_name"]
      rs_aws_iam.instance_profile.add_role({
        instance_profile: @instance_profile.InstanceProfileName,
        role_name: $fields["role_name"]
      })
    end
    sub on_error: skip do
      sleep_until(@instance_profile.InstanceProfileId != null)
    end
    @instance_profile = @instance_profile.get()
    call plugin_generics.stop_debugging()
  end
end

define delete_instance_profile(@instance_profile) do
  $delete_count = 0
  sub on_error: handle_retries($delete_count) do
    $delete_count = $delete_count + 1
    call plugin_generics.start_debugging()
    @instance_profile = @instance_profile.get()
    if @instance_profile
      rs_aws_iam.instance_profile.remove_role({
        instance_profile: @instance_profile.InstanceProfileName,
        role_name: @instance_profile.RoleName
      })
      @instance_profile.destroy()
    end
    call plugin_generics.stop_debugging()
  end
end


define handle_retries($attempts) do
  if $attempts <= 6
    sleep(10*to_n($attempts))
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("error:")
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end
