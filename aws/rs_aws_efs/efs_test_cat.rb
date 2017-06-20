name 'EFS Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic File System - Test CAT"
import "plugins/rs_aws_efs"
import "sys_log"

parameter "performanceMode" do
    label "EFS Performance Mode"
    type "string"
    allowed_values "generalPurpose","maxIO"
    default_value "generalPurpose"
end

parameter "EFSname" do
    label "EFS Name"
    type "string"
    min_length 1
end

parameter "subnet_a" do
    label "EFS - Subnet ID to Mount"
    type "string"
    min_length 1
    description "ie. subnet-12345678"
end

parameter "subnet_b" do
    label "EFS - Subnet ID to Mount"
    type "string"
    min_length 1
    description "ie. subnet-12345678"
end


resource "my_efs", type: "rs_aws_efs.file_systems" do
  creation_token join(["efs-", last(split(@@deployment.href, "/"))])
  performance_mode $performanceMode
  tags do {
    "Key" => "Name",
    "Value" => $EFSname
  } end
end

resource "my_mount", type: "rs_aws_efs.mount_targets" do
  file_system_id @my_efs.FileSystemId
  subnet_id $subnet_a
end

resource "my_mount2", type: "rs_aws_efs.mount_targets" do
  file_system_id @my_efs.FileSystemId
  subnet_id $subnet_b
end

output "list_efs" do
  label "list_fs"
end

output "fs_id" do
  label "fs_id"
  category "EFS"
  default_value @my_efs.FileSystemId
end 

operation "list_efs" do
  definition "list_efs"
  output_mappings do {
    $list_efs => $object
  } end
end

operation "launch" do
  definition "launch_handler"
end

operation "terminate" do
  definition "terminate_me"
end

define launch_handler(@my_efs, @my_mount, @my_mount2) return @my_efs, @my_mount, @my_mount2 do
  provision(@my_efs)
  provision(@my_mount)
  provision(@my_mount2)
end

define terminate_me(@my_efs, @my_mount, @my_mount2) do
  delete(@my_mount)
  delete(@my_mount2)
  delete(@my_efs)
end


define list_efs() return $object do
  @efs = rs_aws_efs.file_systems.list()
  $object = to_object(first(@efs))
  $object = to_s($object)
end
