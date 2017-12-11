name 'EFS Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic File System - Test CAT"
import "plugins/rs_aws_efs"
import "plugins/rs_aws_route53"

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

resource "my_efs", type: "rs_aws_efs.file_systems" do
  creation_token join(["efs-", last(split(@@deployment.href, "/"))])
  performance_mode $performanceMode
  tags do {
    "Key" => "Name",
    "Value" => $efs_name
  } end
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

output "to_base64" do
  label "to_base64"
  category "Base64"
  default_value $tb
end

output "from_base64" do
  label "from_base64"
  category "Base64"
  default_value $fb
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


define launch_handler(@my_efs) return @my_efs,$fb,$tb do
  provision(@my_efs)
  $tb = to_base64("a string")
  $fb = from_base64("YSBzdHJpbmc=")
end

define list_efs() return $object do
  @efs = rs_aws_efs.file_systems.list()
  $object = to_object(first(@efs))
  $object = to_s($object)
end

resource "hostedzone", type: "rs_aws_route53.hosted_zone" do
  create_hosted_zone_request do {
    "xmlns" => "https://route53.amazonaws.com/doc/2013-04-01/",
    "Name" => [ join([first(split(uuid(),'-')), ".rsps.com"]) ],
    "CallerReference" => [ uuid() ]
  } end
end
