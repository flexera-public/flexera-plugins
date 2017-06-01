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
# Test CAT for the gce_plugin.forwardingRule resource


name "GCE Plugin forwardingRule Test"
rs_ca_ver 20161221
short_description "Test CAT for the GCE Plugin forwardingRule resource"
type 'application'

import "sys_log"
import "cat_spec"
import "plugins/gce"

parameter "gce_project" do
  like $gce.gce_project
  default "rightscale.com:services1"
end

parameter "region" do
  type "string"
  label "Region"
  category "Cloud"
  allowed_pattern "^[0-9a-z\-]+$"
  default "us-east1"
end

resource "health_check", type: "gce.httpHealthCheck" do
  name join(["gce-plugin-test-health-check",last(split(@@deployment.name,'-'))])
  description  join(["gce-plugin-test-health-check",last(split(@@deployment.name,'-'))])
end

resource "target_pool", type: "gce.targetPool" do
  region $region
  name join(["gce-plugin-test-target-pool",last(split(@@deployment.name,'-'))])
  description join(["gce-plugin-test-target-pool",last(split(@@deployment.name,'-'))])
  healthChecks @health_check.selfLink
end

resource "forwardingRule", type: "gce.forwardingRule" do
  name join(["gce-plugin-test-",last(split(@@deployment.name,'-'))])
  description "GCE Unit Test forwardingRule"
  region $region
  target @target_pool.selfLink
end

operation "launch" do
  definition "launch"
end

operation "terminate" do
  definition "terminate"
end

define launch(@health_check, @target_pool, @forwardingRule,$gce_project,$region) do
    
  provision(@health_check)
  provision(@target_pool)

  sub task_name: "forwardingRule_provision"  do
    call cat_spec.set_context("Provision gce.forwardingRule")
    $forwardingRule = to_object(@forwardingRule)
    call cat_spec.start_debugging()
    provision(@forwardingRule)
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@forwardingRule,"gce.forwardingRule") on_error: skip
    $expected_values = {"name": $forwardingRule["fields"]["name"], "kind": "compute#forwardingRule"}
    call cat_spec.expect_resource_contains(@forwardingRule,$expected_values) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "get_forwardingRule", on_error: skip do
    call cat_spec.set_context("Action forwardingRule.get")
    call cat_spec.start_debugging()
    @get_forwardingRule = @forwardingRule.get()
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@forwardingRule,"gce.forwardingRule") on_error: skip
    call cat_spec.expect_resource_match(@forwardingRule,@get_forwardingRule) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "list_forwardingRule", on_error: skip do
    call cat_spec.set_context("Action forwardingRule.list")
    call cat_spec.start_debugging()
    @list_forwardingRule = gce.forwardingRule.list({region: $region})
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@list_forwardingRule, "gce.forwardingRule") on_error: skip
    $expect_all_resources = {"kind": "compute#forwardingRule"}
    call cat_spec.expect_all_resources_contain(@list_forwardingRule, $expect_all_resources) on_error: skip
    $expect_contains = {"name": @list_forwardingRule.name, "kind": "compute#forwardingRule"}
    call cat_spec.expect_resource_contains(@list_forwardingRule,$expect_contains) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "agg_list_forwardingRule", on_error: skip do
    call cat_spec.set_context("Action forwardingRule.aggregatedList")
    call cat_spec.start_debugging()
    @agg_list_forwardingRule = gce.forwardingRule.aggregatedList()
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@agg_list_forwardingRule, "gce.forwardingRule") on_error: skip
    $expect_all_resources = {"kind": "compute#forwardingRule"}
    call cat_spec.expect_all_resources_contain(@agg_list_forwardingRule, $expect_all_resources) on_error: skip
    $expect_contains = {"name": @agg_list_forwardingRule.name, "kind": "compute#forwardingRule"}
    call cat_spec.expect_resource_contains(@agg_list_forwardingRule,$expect_contains) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "delete_forwardingRule", on_error: skip do
    call cat_spec.set_context("Delete gce.forwardingRule")
    call cat_spec.start_debugging()
    delete(@target_pool)
    delete(@forwardingRule)
    delete(@health_check)
    call cat_spec.stop_debugging()
    # Not sure what to test here

    call cat_spec.complete_test()
  end

  call cat_spec.compile_results()
end

define terminate(@target_pool, @health_check, @forwardingRule) do
  
  if !empty?(@target_pool)
    delete(@target_pool)
  end

  if !empty?(@health_check)
    delete(@health_check)
  end

  if !empty?(@forwardingRule)
    delete(@forwardingRule)
  end
  
end
