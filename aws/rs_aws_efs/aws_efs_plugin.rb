name 'aws_efs_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic File System"
long_description "Version: 1.0"
package "plugins/rs_aws_efs"
import "sys_log"

plugin "rs_aws_efs" do
  endpoint do
    default_scheme "https"
    path "/2015-02-01"
  end
  
  # http://docs.aws.amazon.com/efs/latest/ug/api-reference.html
  type "file_systems" do
    href_templates "/file-systems?FileSystemId={{FileSystems[*].FileSystemId}}","/file-systems?FileSystemId={{FileSystemId}}"

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

    field "tags" do
      alias_for "Tags"
      type "composite"
    end 

    # Non-create fields
    field "file_system_id" do
      alias_for "FileSystemId"
      type "string"
    end 

    field "tag_keys" do
      alias_for "TagKeys"
      type "array"
    end 
 
    output "OwnerId","CreationToken","PerformanceMode","FileSystemId","CreationTime","LifeCycleState","NumberOfMountTargets"

    output "size" do
      body_path "SizeInBytes.Value"
    end

    output "size_timestamp" do
      body_path "SizeInBytes.Timestamp"
    end 

    # http://docs.aws.amazon.com/efs/latest/ug/API_CreateFileSystem.html
    action "create" do
      verb "POST"
      path "/file-systems"
    end

    # http://docs.aws.amazon.com/efs/latest/ug/API_DeleteFileSystem.html
    action "destroy" do
      verb "DELETE"
      path "/file-systems/$file_system_id"

      field "file_system_id" do
        location "path"
      end 

    end
    
    # http://docs.aws.amazon.com/efs/latest/ug/API_DescribeFileSystems.html
    action "get" do
      verb "GET"

      output_path "FileSystems[]"

    end
    
    # http://docs.aws.amazon.com/efs/latest/ug/API_DescribeFileSystems.html
    action "list" do
      verb "GET"
      path "/file-systems"

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

    # http://docs.aws.amazon.com/efs/latest/ug/API_CreateTags.html
    action "apply_tags" do
      verb "POST"
      path "/create-tags/$file_system_id"

      field "file_system_id" do
        location "path"
      end 

      field "tags" do
        alias_for "Tags"
      end
    end

    # http://docs.aws.amazon.com/efs/latest/ug/API_DeleteTags.html
    action "delete_tags" do
      verb "POST"
      path "/delete-tags/$file_system_id" 

      field "file_system_id" do
        location "path"
      end 

      field "tag_keys" do
        alias_for "TagKeys"
      end
    end

    # http://docs.aws.amazon.com/efs/latest/ug/API_DescribeTags.html
    action "get_tags" do
      verb "GET"
      path "/tags/$file_system_id"

      field "file_system_id" do
        location "path"
      end 
    end 

    provision "provision_efs"

    delete    "delete_efs"
  end

  type "mount_targets" do
    href_templates "/mount-targets?MountTargetId={{MountTargets[*].MountTargetId}}","/mount-targets?MountTargetId={{MountTargetId}}"

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

    # http://docs.aws.amazon.com/efs/latest/ug/API_CreateMountTarget.html
    action "create" do
      verb "POST"
      path "/mount-targets"
    end 

    # http://docs.aws.amazon.com/efs/latest/ug/API_DeleteMountTarget.html
    action "destroy" do
      verb "DELETE"
      path "/mount-targets/$mount_target_id"

      field "mount_target_id" do
        location "path"
      end 

    end

    # http://docs.aws.amazon.com/efs/latest/ug/API_DescribeMountTargets.html
    action "get" do
      verb "GET"

      output_path "MountTargets[]"
    end

    # http://docs.aws.amazon.com/efs/latest/ug/API_DescribeMountTargets.html
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
      path "/file-systems?FileSystemId={{FileSystemId}}"
      type "file_systems"
    end 

    provision "provision_efs"

    delete    "delete_mount"

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

define provision_efs(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $tags = $fields["tags"]
    $type = $object["type"]
    @operation = rs_aws_efs.$type.create($fields)
    $status = @operation.LifeCycleState
    sub on_error: skip, timeout: 10m do
      while $status != "available" do
        $status = @operation.LifeCycleState
        sleep(10)
      end
    end 
    @resource = @operation.get()
    if $tags != null
      $id = @resource.FileSystemId
      @operation.apply_tags(file_system_id: $id, tags: [$tags])
    end 
    call stop_debugging()
  end
end

define delete_efs(@declaration) do
  call start_debugging()
  $state = @declaration.LifeCycleState
  $id = @declaration.FileSystemId
  if $state != "deleting" || $state != "deleted"
      @declaration.destroy(file_system_id: $id)
  end 
  call stop_debugging()
end

define delete_mount(@declaration) do
  call start_debugging()
  sub on_error: skip do
    $state = @declaration.LifeCycleState
    $mount = @declaration.MountTargetId
    if $state != "deleting" || $state != "deleted"
      @declaration.destroy(mount_target_id: $mount)
    end 
    sub on_error: skip do
      @mount = rs_aws_efs.mount_targets.list(mount_target_id: $mount)
      while !empty?(@mount) do
        sleep(10)
        @mount = rs_aws_efs.mount_targets.list(mount_target_id: $mount)
      end
    end 
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
