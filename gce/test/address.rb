name "GCE Plugin Address Test"
rs_ca_ver 20161221
short_description "Test CAT for the GCE Plugin Address resource"
type 'application'

import "sys_log"
import "plugins/gce"

parameter "gce_project" do
  like $gce.gce_project
  default "rightscale.com:services1"
end

parameter "region" do
  type "string"
  label "Region"
  category "Address"
  allowed_pattern "^[0-9a-z\-]+$"
  default "us-east1"
end

resource "address", type: "gce.address" do
  name "gce-plugin-address-test"
  description "GCE Unit Test Address"
  region $region
end

output "insert" do
  label "Address Insert"
  category "Unit Test"
  description "insert action of address"
  default_value $insert_output
end

# output "get" do
#   label "Address Get"
#   category "Unit Test"
#   description "get action of Address"
#   default_value "Untested"
# end

# output "delete" do
#   label "Address Delete"
#   category "Unit Test"
#   description "delete action of address"
#   default_value "Untested"
# end

# output "list" do
#   label "Address List"
#   category "Unit Test"
#   description "list action of Address"
#   default_value "Untested"
# end

# output "aggregatedList" do
#   label "Address AggregatedList"
#   category "Unit Test"
#   description "aggregatedList action of Address"
# end

operation "launch" do
  definition "launch"
  output_mappings do {
$insert => $insert_output
}end
end

operation "terminate" do
  definition "terminate"
#     output_mappings do {
# $delete => $delete_result
# }end
end

# operaiton "get" do
#   label "Get Test"
#   definition "get"
#   description "Assert the get action returns an expected address resource"
# end

# operation "list" do
#   label "List Test"
#   definition "list"
#   description "Assert the list action returns a list of address resources"
# end

# operation "aggregatedList" do
#   label "AggregatedList Test"
#   definition "aggregatedList"
#   description "Assert the aggregatedList action returns a list of address resources"
# end

define launch(@address,$gce_project,$region) return @address,$insert_output do
  $parameters = {"GCE Project": $gce_project, "Region": $region}
  call log_parameters($parameters)
  
  $address = to_object(@address)
  $insert_tests = {"status": "RESERVED", "name": $address["fields"]["name"], "kind": "compute#address"}

  call insert(@address, $insert_tests) retrieve @address,$insert_result
  call eval_result($insert_result) retrieve $insert_output

  #call get(@address, $get_tests) retrieve $get_result
  #call list($list_tests) retrieve $list_result
  #call aggregate_list($agg_list_tests) retrieve $agg_list_result
  #call delete(@address) retrieve $delete_result
end

define terminate(@address) return $delete_result do
  $delete_result = "Untested"
  delete(@address)
  $delete_result = "PASS"
end

define insert(@address, $insert_tests) return @address, $insert_result on_error: stop_debugging() do
  call log_resource(@address)
  #call start_debugging()
  provision(@address)
  #call stop_debugging()
  call log_resource(@address)
  call test_resource(@address, "gce.address", $insert_tests) retrieve $insert_result
end

define eval_result($result) return $eval do
  if $result
    $eval = "PASS"
  else
    $eval = "FAIL"
  end
end

define test_resource(@resource, $resource_type, $test_hash) return $result do
  $result = false
  $type_pass = false
  $field_pass = false

  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Resource Test Results")
  call sys_log.detail(join(["Field Tests: ",$test_hash]))
  
  if type(@resource) == $resource_type
    $type_pass = true
    call sys_log.detail("Type Test - PASS")
  else
    $type_pass = false
    call sys_log.detail("Type Test - FAIL")
  end
      call sys_log.detail(join(["Found/Expected: ",type(@resource)," | ",$resource_type]))

  $field_test_array = []
  if $type_pass
    $resource_details = to_object(@resource)["details"][0]
    foreach $key in keys($test_hash) do
      if $resource_details[$key] == $test_hash[$key]
        $field_test_array << true
      else
        $field_test_array << false
      end
      call sys_log.detail(join(["Field (Found/Expected): ",$resource_details[$key]," | ",$test_hash[$key]]))
    end
  end
  call sys_log.detail(join(["Field Test Array: ",to_s($field_test_array)]))
  if size($field_test_array) == size($test_hash) && $type_pass && all?($field_test_array)
    $result = true
    call sys_log.summary("Resource Test Result: PASS")
  else
    $result = false
    call sys_log.summary("Resource Test Result: FAIL")
  end
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
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Debug Report")
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end

define log_resource(@resource) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Resource Details")
  call sys_log.detail(to_object(@resource))
end

define log_parameters($parameters) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("CAT Parameters")
  foreach $key in keys($parameters) do
    call sys_log.detail(join([$key,": ",$parameters[$key]]))
  end
end
