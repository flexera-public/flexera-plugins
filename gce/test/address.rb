# Copyright (c) 2017 RightScale-Engineering

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# RightScale Cloud Application Template (CAT)

# DESCRIPTION
# Test CAT for the gce_plugin.address resource


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
  name join(["gce-plugin-test-",last(split(@@deployment.name,'-'))])
  description "GCE Unit Test Address"
  region $region
end

output "insert_test" do
  label "Address Insert Test"
  category "Unit Tests"
  description "insert action of address"
  default_value "Untested"
end

output "get_test" do
  label "Address Get Test"
  category "Unit Tests"
  description "get action of Address"
  default_value "Untested"
end

output "list_test" do
  label "Address List Test"
  category "Unit Tests"
  description "list action of Address"
  default_value "Untested"
end

output "agg_list_test" do
  label "Address Aggregated List Test"
  category "Unit Tests"
  description "aggregatedList action of Address"
  default_value "Untested"
end

output "delete_test" do
  label "Address Delete Test"
  category "Unit Tests"
  description "delete action of Address"
  default_value "Untested"
end

operation "launch" do
  definition "launch"
  output_mappings do {
$insert_test => $insert_result,
$get_test => $get_result,
$list_test => $list_result,
$agg_list_test => $agg_list_result,
$delete_test => $delete_result
}end
end

define launch(@address,$gce_project,$region) return @address,$insert_result,$get_result,$list_result,$agg_list_result,$delete_result do
  $result_array = []
  $parameters = {"GCE Project": $gce_project, "Region": $region}
  call log_parameters($parameters)
  
  $address = to_object(@address)
  $insert_tests = {"status": "RESERVED", "name": $address["fields"]["name"], "kind": "compute#address"}
  
  call insert_test(@address, $insert_tests) retrieve @address, $insert_result
  $result_array << $insert_result
  
  call get_test(@address) retrieve $get_result
  $result_array << $get_result

  $list_tests = {"region": join(["https://www.googleapis.com/compute/v1/projects/",$gce_project,"/regions/",$region]), "kind": "compute#address"}
  call list_test({"region": $region},$list_tests) retrieve $list_result
  $result_array << $list_result

  $agg_list_tests = {"kind": "compute#address"}
  call aggregatedlist_test({},$agg_list_tests) retrieve $agg_list_result
  $result_array << $agg_list_result

  call delete_test(@address) retrieve $delete_result
  $result_array << $delete_result

  call evaluate_results($result_array)
end

define insert_test(@address, $insert_tests) return @address, $result on_error: stop_debugging() do
  $insert_result = false
  call log_resource(@address)
  #call start_debugging()
  provision(@address)
  #call stop_debugging()
  call log_resource(@address)
  call test_resource(@address, ["gce.address"], $insert_tests) retrieve $insert_result
  call eval_result($insert_result) retrieve $result
end

define get_test(@address) return $result on_error: stop_debugging() do
  $get_result = false
  call log_resource(@address)
  call start_debugging()
  @get_address = @address.get()
  call stop_debugging()
  call log_resource(@get_address)
  if @get_address == @address
    $get_result = true
  else
    $get_result = false
  end
  call eval_result($get_result) retrieve $result
end

define list_test($fields,$list_tests) return $result on_error: stop_debugging() do
  $result = "Untested"
  call start_debugging()
  @address_collection = gce.address.list($fields)
  call stop_debugging()
  call log_resource(@address_collection)
  call test_resource(@address_collection, ["array","gce.address"], $list_tests) retrieve $list_result
  call eval_result($list_result) retrieve $result
end

define aggregatedlist_test($fields,$agg_list_tests) return $result on_error: stop_debugging() do
  $result = "Untested"
  call start_debugging()
  @address_collection = gce.address.aggregatedList($fields)
  call stop_debugging()
  call log_resource(@address_collection)
  call test_resource(@address_collection, ["array","gce.address"], $agg_list_tests) retrieve $agg_list_result
  call eval_result($agg_list_result) retrieve $result
end

define delete_test(@address) return $result on_error: stop_debugging() do
  $result = "Untested"
  $address_region = last(split(@address.region,"/"))
  $address_name = @address.name
  call start_debugging()
  delete(@address)
  call stop_debugging()
  @address_collection = gce.address.list({"region": $region, "filter": join(["name"," ","=="," ",$address_name])})
  call log_resource(@address_collection)
  if empty?(@address_collection)
    $result = true
  else
    $result = false
  end
end


######################################################
######### Test Utilities Below This Line

define record_results($result_array,$result) return $result_array do
  $result_array << $result
end

define evaluate_results($result_array) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Final Result")
  if any?($result_array, "FAIL")
    call sys_log.summary("Final Result: FAIL")
    call sys_log.detail(to_s($result_hash))
    raise "One or more unit tests failed"
  else
    call sys_log.summary("Final Result: PASS")
  end
end

define eval_result($result) return $eval do
  if $result == null
    $eval = false
  else
    $eval = switch($result,"PASS","FAIL")
  end
end

define test_resource(@resource, $resource_type, $test_hash) return $result do
  $result = false
  $type_pass = false
  $field_pass = false
  $type = null

  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Resource Test Results")
  call sys_log.detail(join(["Field Tests: ",$test_hash]))
  
  if contains?($resource_type,[type(@resource)])
    $type_pass = true
    $type = type(@resource)
    call sys_log.detail("Type Test - PASS")
  else
    $type_pass = false
    call sys_log.detail("Type Test - FAIL")
  end
      call sys_log.detail(join(["Found/Expected: ",type(@resource)," | ",$resource_type]))

  $field_test_array = []
  if $type_pass
    if $type == "array"
      foreach @item in @resource do
        $resource_details = to_object(@item)["details"][0]
        foreach $key in keys($test_hash) do
          if $resource_details[$key] == $test_hash[$key]
            $field_test_array << true
          else
            $field_test_array << false
          end
          call sys_log.detail(join(["Field (Found/Expected): ",$resource_details[$key]," | ",$test_hash[$key]]))
        end
      end
    else
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
