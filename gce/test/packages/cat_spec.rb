# Copyright (c) 2017 RightScale, Inc

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


# TODO: Documentation
# TODO: raise should explain why it failed. Iterate the results global and print one line for each failure.
# TODO: Audits should be created in debug mode?
# - How will this effect packages that are tested with the framework but imported for production use?  

name "Package: cat_spec"
rs_ca_ver 20161221
short_description "Collection of definitions for testing Cloud Application Templates"
package "cat_spec"
import "sys_log"

#####################
##   Expect Tests  ##

define expect_type_eq(@resource, $type) on_error: error_handler() do
  call sys_log.set_task_target(@@deployment)
  $$test = {"name": join(["is of type ",$type]), "result": ""}
  call sys_log.summary(join([$$context["name"],": ",$$test["name"]]))
  call sys_log.detail(join(["Resource Object: ", to_object(@resource)]))
  call sys_log.detail(join(["Expected Type: ", $type]))
  assert type(@resource) == $type
  call sys_log.detail(join(["#### UNIT TEST PASSED ####"]))
  call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - PASSED"]))
  $$test["result"] = "PASSED"
  call add_test_to_context()
end

# If a single resource, it must match all tests
# If a resource collection, only one of the resources must match all tests
define expect_resource_contains(@resource, $test_hash) on_error: error_handler() do
  call sys_log.set_task_target(@@deployment)
  $$test = {"name": join(["contains hash values"]), "result": ""}
  call sys_log.summary(join([$$context["name"],": ",$$test["name"]]))
  call sys_log.detail(join(["Resource Object: ",to_object(@resource)]))
  
  if size(@resource) == 1
    $field_test_array = []
    $resource_details = to_object(@resource)["details"][0]
    foreach $key in keys($test_hash) do
      if $resource_details[$key] == $test_hash[$key]
        $field_test_array << true
      else
        $field_test_array << false
      end
      call sys_log.detail(join(["Field (Found/Expected): ",$resource_details[$key]," | ",$test_hash[$key]]))
    end
  
    call sys_log.detail(join(["Field Test Array: ",to_s($field_test_array)]))
    assert size($field_test_array) == size($test_hash) && all?($field_test_array)
    call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - PASSED"]))
    $$test["result"] = "PASSED"
    call add_test_to_context()
  elsif size(@resource) > 1
    $resource_detail_array = to_object(@resource)["details"]
    $resource_test_array = []
    foreach $resource_details in $resource_detail_array do
      $field_test_array = []
      foreach $key in keys($test_hash) do
        if $resource_details[$key] == $test_hash[$key]
          $field_test_array << true
        else
          $field_test_array << false
        end
        call sys_log.detail(join(["Field (Found/Expected): ",$resource_details[$key]," | ",$test_hash[$key]]))
      end
      call sys_log.detail(join(["Field Test Array: ",to_s($field_test_array)]))
      if size($field_test_array) == size($test_hash) && all?($field_test_array)
        $resource_test_array << true
      else
        $resource_test_array << false
      end
    end

    assert size($resource_test_array) == size(@resource) && any?($resource_test_array)
    call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - PASSED"]))
    $$test["result"] = "PASSED"
    call add_test_to_context()
  else
    raise "Empty resource or size of resource < 1"
  end
end

# All resources must match all tests
define expect_all_resources_contain(@resource, $test_hash) on_error: error_handler() do
  call sys_log.set_task_target(@@deployment)
  $$test = {"name": join(["all contain hash values"]), "result": ""}
  call sys_log.summary(join([$$context["name"],": ",$$test["name"]]))
  call sys_log.detail(join(["Resource Object: ", to_object(@resource)]))
  
  if size(@resource) == 1
    $field_test_array = []
    $resource_details = to_object(@resource)["details"][0]
    foreach $key in keys($test_hash) do
      if $resource_details[$key] == $test_hash[$key]
        $field_test_array << true
      else
        $field_test_array << false
      end
      call sys_log.detail(join(["Field (Found/Expected): ",$resource_details[$key]," | ",$test_hash[$key]]))
    end
  
    call sys_log.detail(join(["Field Test Array: ",to_s($field_test_array)]))
    assert size($field_test_array) == size($test_hash) && all?($field_test_array)
    call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - PASSED"]))
    $$test["result"] = "PASSED"
    call add_test_to_context()
  elsif size(@resource) > 1
    $resource_detail_array = to_object(@resource)["details"]
    $resource_test_array = []
    foreach $resource_details in $resource_detail_array do
      $field_test_array = []
      foreach $key in keys($test_hash) do
        if $resource_details[$key] == $test_hash[$key]
          $field_test_array << true
        else
          $field_test_array << false
        end
        call sys_log.detail(join(["Field (Found/Expected): ",$resource_details[$key]," | ",$test_hash[$key]]))
      end
      call sys_log.detail(join(["Field Test Array: ",to_s($field_test_array)]))
      if size($field_test_array) == size($test_hash) && all?($field_test_array)
        $resource_test_array << true
      else
        $resource_test_array << false
      end
    end

    assert size($resource_test_array) == size(@resource) && all?($resource_test_array)
    call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - PASSED"]))
    $$test["result"] = "PASSED"
    call add_test_to_context()
  else
    raise "Empty resource or size of resource < 1"
  end
end

define expect_resource_match(@resource, @test_resource) on_error: error_handler() do
  call sys_log.set_task_target(@@deployment)
  $$test = {"name": join(["resources match"]), "result": ""}
  call sys_log.summary(join([$$context["name"],": ",$$test["name"]]))
  assert @resource == @test_resource
  call sys_log.detail(join(["#### UNIT TEST PASSED ####"]))
  call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - PASSED"]))
  $$test["result"] = "PASSED"
  call add_test_to_context()
end


#####################################
##  Test Management Functions  ##

define set_context($context) do
  if $$context != null
    call complete_test()
  end
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary($context)
  task_label($context)
  if $$results == null
    $$results = {"contexts": [], "result": ""}
  end
  $$context = {"name": $context, "tests": [], "result": ""}
end

define complete_test() do
  if $$context["result"] != "FAILED"
    $$context["result"] = "PASSED"
  end
  call add_context_to_results()
  call clear_context()
end

define compile_results() do
  if $$context != null
    call complete_test()
  end
  call sys_log.set_task_target(@@deployment)
  if $$results["result"] != "FAILED"
    $$results["result"] = "PASSED"
  end
  call sys_log.summary(join(["Test Results: ",$$results["result"]]))
  call sys_log.detail($$results)
  if $$results["result"] == "FAILED"
    raise $$results
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
    call sys_log.detail(join(["Debug Report: ",$debug_report]))
    $$debugging = false
  end
end

########
define add_test_to_context() do
  $test_array = $$context["tests"]
  $test_array << $$test
  $$context["tests"] = $test_array
  $$test = null
end

define add_context_to_results() do
  $context_array = $$results["contexts"]
  $context_array << $$context
  $$results["contexts"] = $context_array
  $$context = null
end

define error_handler() do
  if $$test != null && $$context != null && $$results != null
    call sys_log.summary(join([$$context["name"],": ",$$test["name"]," - FAILED"]))
    $$test["result"] = "FAILED"
    call add_test_to_context()
    $$context["result"] = "FAILED"
    $$results["result"] = "FAILED"
  end
  call sys_log.detail(join(["Error: ",$_error]))
  call stop_debugging()
  call sys_log.detail(join(["#### TEST FAILED ####"]))
  raise $_error
end

define clear_context() do
  $$context = null
  $$test = null
end
