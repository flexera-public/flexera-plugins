name 'aws_efs_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic File System"
package "plugins/rs_aws_efs"
import "sys_log"

plugin "rs_aws_efs" do
  endpoint do
    default_scheme "https"
    path "/2015-02-01/file-systems"
  end
 
  type "file_systems" do
    href_templates "?FileSystemId={{FileSystems[*].FileSystemId}}","?FileSystemId={{FileSystemId}}"

    field "creation_token" do
      alias_for "CreationToken"
      type "string"
      required true
    end
 
    field "performance_mode" do
      alias_for "PerformanceMode"
      type      "string"
      # Allowed Values: generalPurpose | maxIO
    end

    # Non-create fields
    field "file_system_id" do
      alias_for "FileSystemId"
      type "string"
    end 
 
    output "OwnerId","CreationToken","PerformanceMode","FileSystemId","CreationTime","LifeCycleState","NumberOfMountTargets"

    output "size" do
      body_path "SizeInBytes.Value"
    end

    output "size_timestamp" do
      body_path "SizeInBytes.Timestamp"
    end 

    action "create" do
      verb "POST"
      path "/"
    end

    action "destroy" do
      verb "DELETE"
      path "/file-systems/$href"
    end
 
    action "get" do
      verb "GET"
      #path "/file-systems?FileSystemId=$FileSystemId"

      output_path "FileSystems[]"

    end

    action "show" do
      verb "GET"
      path "/"

      field "file_system_id" do
        alias_for "FileSystemId"
        location "query"
      end

      output_path "FileSystems[]"

    end
 
    action "list" do
      verb "GET"
      path "/"

      field "creation_token" do
        alias_for "CreationToken"
        location "query"
      end

      field "file_system_id" do
        alias_for "FileSystemId"
        location "query"
      end 

      output_path "FileSystems[]"

    end

    provision "provision_fs"

    delete    "delete_fs"
  end

  type "mount_targets" do
    href_templates "{{MountTargetId}}"

    field "file_system_id" do
      alias_for "FileSystemId"
      type "string"
      required true
    end 

    field "ip_address" do
      alias_for "IpAddress"
      type "string"
    end 

    field "security_groups" do
      alias_for "SecurityGroups"
      type "array"
    end 

    field "subnet_id" do
      alias_for "SubnetId"
      type "string"
      required true
    end 

    # Non-create fields
    field "mount_target_id" do
      alias_for "MountTargetId"
      type "string"
    end     

    output "FileSystemId","IpAddress","LifeCycleState","MountTargetId","NetworkInterfaceId","OwnerId","SubnetId"

    action "create" do
      verb "POST"
      path "/mount-targets"
    end 

    action "destroy" do
      verb "DELETE"
      path "/mount-targets/$href"
    end

    action "get" do
      verb "GET"
      path "/mount-targets?MountTargetId=$href"

      output_path "MountTargets[]"
    end

    action "list" do
      verb "GET"
      path "/mount-targets"

      field "file_system_id" do
        alias_for "FileSystemId"
        location "query"
      end 

      field "mount_target_id" do
        alias_for "MountTargetId"
        location "query"
      end 

      output_path "MountTargets[]"
    end

    link "file_systems" do
      path "{{FileSystemId}}"
      type "file_systems"
    end 

  end

  type "efs_tags" do
    href_templates "{{}}"

    field "file_system_id" do
      alias_for "FileSystemId"
      type "string"
      location "path"
    end 

    field "tags" do
      alias_for "Tags"
      type "composite"
      required true
    end 
  
  end
    

end

resource_pool "efs" do
  plugin $rs_aws_efs
  host "elasticfilesystem.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'elasticfilesystem'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

resource "my_efs", type: "rs_aws_efs.file_systems" do
  creation_token join(["dfefs-", last(split(@@deployment.href, "/"))])
  performance_mode "generalPurpose"
end

output "list_efs" do
  label "list_action"
end

output "fs_id" do
  label "fs_id"
  default_value @my_efs.FileSystemId
end 

operation "list_efs" do
  definition "list_efs"
  output_mappings do {
    $list_efs => $object
  } end
end

define provision_fs(@declaration) return @efs do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    @file_system = rs_aws_efs.file_systems.create($fields)
    #$status = @file_system.LifeCycleState
    #sub on_error: skip, timeout: 10m do
    #  while $status != "available" do
    #    $status = @file_system.LifeCycleState
    #    sleep(10)
    #  end
    #end 
    $file_system_obj = to_object(@file_system)
    $file_system_id = $file_system_obj["FileSystemId"]
    @efs = @file_system.get(file_system_id: $file_system_id)
    call stop_debugging()
  end
end

define list_efs() return $object do
  call start_debugging()
  @efs = rs_aws_efs.file_systems.list()
  $object = to_object(first(@efs))
  $object = to_s($object)
  call stop_debugging()
end

define delete_fs(@efs) do
  call start_debugging()
  $file_system_obj = to_object(@efs)
  $state = $file_system_obj["fields"]["LifeCycleState"]
  $id = $file_system_obj["fields"]["FileSystemId"]
  if $state != "deleting" || $state != "deleted"
    @efs.destroy()
  end 
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
