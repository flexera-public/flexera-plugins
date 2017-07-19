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
import "cat_spec"
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

operation "launch" do
  definition "launch"
end

operation "terminate" do
  definition "terminate"
end

define launch(@address,$gce_project,$region) do
      
  sub task_name: "address_provision"  do
    call cat_spec.set_context("Provision gce.address")
    $address = to_object(@address)
    call cat_spec.start_debugging()
    provision(@address)
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@address,"gce.address") on_error: skip
    $expected_values = {"status": "RESERVED", "name": $address["fields"]["name"], "kind": "compute#address"}
    call cat_spec.expect_resource_contains(@address,$expected_values) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "get_address", on_error: skip do
    call cat_spec.set_context("Action address.get")
    call cat_spec.start_debugging()
    @get_address = @address.get()
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@address,"gce.address") on_error: skip
    call cat_spec.expect_resource_match(@address,@get_address) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "list_addresses", on_error: skip do
    call cat_spec.set_context("Action address.list")
    call cat_spec.start_debugging()
    @list_addresses = gce.address.list({region: $region})
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@list_addresses, "gce.address") on_error: skip
    $expect_all_resources = {"kind": "compute#address"}
    call cat_spec.expect_all_resources_contain(@list_addresses, $expect_all_resources) on_error: skip
    $expect_contains = {"status": "RESERVED", "name": @address.name, "kind": "compute#address"}
    call cat_spec.expect_resource_contains(@list_addresses,$expect_contains) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "agg_list_addresses", on_error: skip do
    call cat_spec.set_context("Action address.aggregatedList")
    call cat_spec.start_debugging()
    @agg_list_addresses = gce.address.aggregatedList()
    call cat_spec.stop_debugging()
    call cat_spec.expect_type_eq(@agg_list_addresses, "gce.address") on_error: skip
    $expect_all_resources = {"kind": "compute#address"}
    call cat_spec.expect_all_resources_contain(@agg_list_addresses, $expect_all_resources) on_error: skip
    $expect_contains = {"status": "RESERVED", "name": @address.name, "kind": "compute#address"}
    call cat_spec.expect_resource_contains(@agg_list_addresses,$expect_contains) on_error: skip
    call cat_spec.complete_test()
  end

  sub task_name: "delete_address", on_error: skip do
    call cat_spec.set_context("Delete gce.address")
    call cat_spec.start_debugging()
    delete(@address)
    call cat_spec.stop_debugging()
    # Not sure what to test here
    # @address should now be empty but @address.get() will probably error
    # list and aggList actions will no longer return results but SS will error if action returns no results
    call cat_spec.complete_test()
  end

  call cat_spec.compile_results()
end

define terminate(@address) do
  # @address should already be deleted by now. But if its not
  # What should the test be to see if the address still exists? empty?
  if !empty?(@address)
    delete(@address)
  end
end
