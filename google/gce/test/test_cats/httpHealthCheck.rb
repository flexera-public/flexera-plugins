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


name "GCE Plugin httpHealthCheck Test"
rs_ca_ver 20161221
short_description "Test CAT for the GCE Plugin httpHealthCheck resource"
type 'application'

import "sys_log"
import "cat_spec"
import "plugins/gce"

parameter "gce_project" do
  like $gce.gce_project
  default "rightscale.com:services1"
end

resource "http_health", type: "gce.httpHealthCheck" do
  name join(["gce-plugin-test-",last(split(@@deployment.name,'-'))])
  description "GCE Unit Test httpHealthCheck"
end

operation "launch" do
  definition "launch"
end

operation "terminate" do
  definition "terminate"
end

define launch(@http_health,$gce_project) do
      
  sub task_name: "http_health_provision"  do
    call cat_spec.set_context("Provision gce.httpHealthCheck")
    $http_health = to_object(@http_health)
    call cat_spec.start_debugging()
    provision(@http_health)
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@http_health,"gce.httpHealthCheck") on_error: skip
    $expected_values = {"description": $http_health["fields"]["description"], "name": $http_health["fields"]["name"], "kind": "compute#httpHealthCheck"}
    call cat_spec.expect_resource_contains(@http_health,$expected_values) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "get_httpHealthCheck", on_error: skip do
    call cat_spec.set_context("Action httpHealthCheck.get")
    call cat_spec.start_debugging()
    @get_httpHealthCheck = @http_health.get()
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@http_health,"gce.httpHealthCheck") on_error: skip
    call cat_spec.expect_resource_match(@http_health,@get_httpHealthCheck) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "list_httpHealthCheck", on_error: skip do
    call cat_spec.set_context("Action httpHealthCheck.list")
    call cat_spec.start_debugging()
    @list_httpHealthCheckes = gce.httpHealthCheck.list()
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@list_httpHealthCheckes, "gce.httpHealthCheck") on_error: skip
    $expect_all_resources = {"kind": "compute#httpHealthCheck"}
    call cat_spec.expect_all_resources_contain(@list_httpHealthCheckes, $expect_all_resources) on_error: skip
    $expect_contains = {"name": @http_health.name, "kind": "compute#httpHealthCheck"}
    call cat_spec.expect_resource_contains(@list_httpHealthCheckes,$expect_contains) on_error: skip
    call cat_spec.complete_test()
  end

  #Update the description and test that it changed
  sub task_name: "patch_httpHealthCheckes", on_error: skip do
    call cat_spec.set_context("Action httpHealthCheck.patch")
    call cat_spec.start_debugging()
    $patch_object = {"description": "GCE Unit Test httpHealthCheck PATCHED"}
    @operation = @http_health.patch($patch_object)
    call wait_for_operation_done(@operation) retrieve @http_health
    call cat_spec.stop_debugging()
    $expect_resource = {"kind": "compute#httpHealthCheck", "description": "GCE Unit Test httpHealthCheck PATCHED"}
    call cat_spec.expect_resource_contains(@http_health, $expect_resource) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "update_httpHealthCheckes", on_error: skip do
    call cat_spec.set_context("Action httpHealthCheck.update")
    call cat_spec.start_debugging()
    $update_object = {"description": "GCE Unit Test httpHealthCheck UPDATED"}
    @operation = @http_health.update($update_object)
    call wait_for_operation_done(@operation) retrieve @http_health
    call cat_spec.stop_debugging()
    $expect_resource = {"kind": "compute#httpHealthCheck", "description": "GCE Unit Test httpHealthCheck UPDATED"}
    call cat_spec.expect_resource_contains(@http_health, $expect_resource) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "delete_httpHealthCheck", on_error: skip do
    call cat_spec.set_context("Delete gce.httpHealthCheck")
    call cat_spec.start_debugging()
    delete(@http_health)
    call cat_spec.stop_debugging()
    # Not sure what to test here
    # @http_health should now be empty but @http_health.get() will probably error
    # list and aggList actions will no longer return results but SS will error if action returns no results
    call cat_spec.complete_test()
  end

  call cat_spec.compile_results()
end

define terminate(@http_health) do
  # @http_health should already be deleted by now. But if its not
  # What should the test be to see if the httpHealthCheck still exists? empty?
  if !empty?(@http_health)
    delete(@http_health)
  end
end

define wait_for_operation_done(@operation) return @resource do
  sub timeout: 2m, on_timeout: skip do
    sleep_until(@operation.status == "DONE")
  end
  @resource = @operation.targetLink()
end
