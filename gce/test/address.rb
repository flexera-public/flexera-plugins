name "GCE Plugin Address Test"
rs_ca_ver 20161221
short_description "Test CAT for the GCE Plugin Address resource"
type 'application'

import "sys_log"
import "plugins/gce_regional", as: 'gce'

parameter "gce_project" do
  like $gce.gce_project
  default "rightscale.com:services1"
end

parameter "gce_region" do
  like $gce.gce_region
  default "us-east1"
end

resource "address", type: "gce.address" do
  name "gce-plugin-address-test"
  description "GCE Unit Test Address"
  region "us-east1"
end

output "insert" do
  label "Address Insert Min"
  category "Unit Test"
  description "Create address with only required fields"
  default_value "Untested"
end

output "delete" do
  label "Address Delete"
  category "Unit Test"
  description "delete action of address"
  default_value "Untested"
end

output "destroy" do
  label "Address Destroy"
  category "Unit Test"
  description "SS destroy action of address"
  default_value "Untested"
end

output "show" do
  label "Address Show"
  category "Unit Test"
  description "SS show action of address"
  default_value "Untested"
end
  
output "list" do
  label "Address List"
  category "Unit Test"
  description "list action of Address"
  default_value "Untested"
end

output "get" do
  label "Address Get"
  category "Unit Test"
  description "get action of Address"
  default_value "Untested"
end

output "aggregatedList" do
  label "Address AggregatedList"
  category "Unit Test"
  description "aggregatedList action of Address"
end

operation "launch" do
  definition "launch"
end

operation "terminate" do
  definition "terminate"
end

define address_launch(@address_min,@address_max,$gce_project,$gce_region) return @address_min,@address_max do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Launch")
  provision(@address_min)
  provision(@address_max)
end

define address_terminate(@address_min,@address_max) do
  delete(@address_min)
  delete(@address_max)
end

