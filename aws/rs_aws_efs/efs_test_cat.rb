name 'EFS Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic File System - Test CAT"
import "plugins/rs_aws_efs"

parameter "performanceMode" do
    label "EFS Performance Mode"
    type "string"
    allowed_values "generalPurpose","maxIO"
    default "generalPurpose"
end

parameter "efs_name" do
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
    "Value" => $efs_name
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
  label "ID"
  category "File System"
  default_value @my_efs.FileSystemId
end 

output "fs_oid" do
  label "OwnerID"
  category "File System"
  default_value @my_efs.OwnerId
end 

output "fs_token" do
  label "Creation Token"
  category "File System"
  default_value @my_efs.CreationToken
end 

output "fs_perf" do
  label "Performance Mode"
  category "File System"
  default_value @my_efs.PerformanceMode
end 

output "fs_time" do
  label "Creation Time"
  category "File System"
  default_value @my_efs.CreationTime
end 

output "fs_lifecycle" do
  label "LifeCycle State"
  category "File System"
  default_value @my_efs.LifeCycleState
end 

output "fs_mounts" do
  label "Number of Mount Targets"
  category "File System"
  default_value @my_efs.NumberOfMountTargets
end 

output "mount_a_ip" do
  label "IP Address"
  category "Mount Target A"
  default_value @my_mount.IpAddress
end 

output "mount_a_id" do
  label "Mount Target ID"
  category "Mount Target A"
  default_value @my_mount.MountTargetId
end

output "mount_a_int_id" do
  label "Network Interface ID"
  category "Mount Target A"
  default_value @my_mount.NetworkInterfaceId
end

output "mount_a_sub" do
  label "Subnet ID"
  category "Mount Target A"
  default_value @my_mount.SubnetId
end

output "mount_a_oid" do
  label "Owner ID"
  category "Mount Target A"
  default_value @my_mount.OwnerId 
end

output "mount_a_fsid" do
  label "File System ID"
  category "Mount Target A"
  default_value @my_mount.FileSystemId
end

output "mount_a_lifecycle" do
  label "LifeCycle State"
  category "Mount Target A"
  default_value @my_mount.LifeCycleState
end

output "mount_b_ip" do
  label "IP Address"
  category "Mount Target B"
  default_value @my_mount2.IpAddress
end 

output "mount_b_id" do
  label "Mount Target ID"
  category "Mount Target B"
  default_value @my_mount2.MountTargetId
end

output "mount_b_int_id" do
  label "Network Interface ID"
  category "Mount Target B"
  default_value @my_mount2.NetworkInterfaceId
end

output "mount_b_sub" do
  label "Subnet ID"
  category "Mount Target B"
  default_value @my_mount2.SubnetId
end

output "mount_b_oid" do
  label "Owner ID"
  category "Mount Target B"
  default_value @my_mount2.OwnerId 
end

output "mount_b_fsid" do
  label "File System ID"
  category "Mount Target B"
  default_value @my_mount2.FileSystemId
end

output "mount_b_lifecycle" do
  label "LifeCycle State"
  category "Mount Target B"
  default_value @my_mount2.LifeCycleState
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


define launch_handler(@my_efs, @my_mount, @my_mount2) return @my_efs, @my_mount, @my_mount2 do
  provision(@my_efs)
  provision(@my_mount)
  provision(@my_mount2)
end



define list_efs() return $object do
  @efs = rs_aws_efs.file_systems.list()
  $object = to_object(first(@efs))
  $object = to_s($object)
end
