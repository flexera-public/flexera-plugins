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
# Example Application CAT for creating an External Network Load Balancer.
# This CAT was developed using the documentation below.
# https://cloud.google.com/compute/docs/load-balancing/network/example

name "Google External Network LB Implementation"
rs_ca_ver 20161221
short_description "Example Google External Network LB Implementation"
long_description "Example Application CAT for creating an External Network Load Balancer.\n
[GCE Network Loadbalancer Docs] (https://cloud.google.com/compute/docs/load-balancing/network/example)
"
type 'application'

import "sys_log"
import "plugins/gce"

# The GCE Project to create resources in
parameter "gce_project" do
  like $gce.gce_project
end

parameter "web_inst_type" do
  type "string"
  label "Web Array Instance Type"
  category "Web Array"
  description "The instance type to use for this instance"
  default "g1-small"
end

parameter "web_st_name" do
  type "string"
  label "Web Array Server Template"
  category "Web Array"
  description "ServerTemplate Name for the web array"
  default "RightLink 10.6.0 GCE Ubuntu 16"
end

parameter "web_st_rev" do
  type "string"
  label "Web Array Server Template Revision"
  category "Web Array"
  description "ServerTemplate Revision for the web array"
  default "HEAD"
end

parameter "web_sec_groups" do
  type "string"
  label "Web Array Security Groups"
  category "Web Array"
  description "Web Array Security Groups"
  default ""
end

parameter "web_datacenter" do
  type "string"
  label "Web Array Datacenter"
  category "Web Array"
  description "Web Array Datacenter"
  default ""
end

parameter "web_subnets" do
  type "string"
  label "Web Array Subnets"
  category "Web Array"
  description "Web Array Subnets"
  default ""
end

parameter "lb_name" do
  type "string"
  label "LB Name"
  category "GCE External LB"
  description "The prefix for resrouces created in this CloudApp"
  default "gce-plugin"
  allowed_pattern "^[0-9a-z\-]+$"
end

parameter "lb_region" do
  type "string"
  label "LB Region"
  category "GCE External LB"
  description "The region to create the loadbalancer in"
  default "us-east1"
  allowed_pattern "^[0-9a-z\-]+$"
end


resource "elb_address", type: "gce.address" do
  region $lb_region
  name join([$lb_name,"-ip"])
  description join([$lb_name,"-ip"])
end

resource "elb_health", type: "gce.httpHealthCheck" do
  name join([$lb_name,"-health-check"])
  description  join([$lb_name,"-health-check"])
end

resource "elb_target_pool", type: "gce.targetPool" do
  region $lb_region
  name join([$lb_name,"-target-pool"])
  description join([$lb_name,"-target-pool"])
  healthChecks @elb_health.selfLink
end

resource "elb_forwarding_rule", type: "gce.forwardingRule" do
  region $lb_region
  name join([$lb_name,"-forwarding-rule"])
  description join([$lb_name,"-forwarding-rule"])
  ipProtocol "TCP"
  ipAddress @elb_address.address
  loadBalancingScheme "EXTERNAL"
  portRange "80-80"
  target @elb_target_pool.selfLink
end

resource "web_array", type: "server_array" do
  name join([$lb_name,"-webarray"])
  cloud "Google"
  instance_type $web_inst_type
  server_template find($web_st_name, {revision: $web_st_rev})
  security_groups $web_sec_groups
  datacenter $web_datacenter
  subnets $web_subnets
  array_type "alert"
  elasticity_params do {
      'bounds' => {
        'min_count' => '2',
        'max_count' => '2',},
      'pacing' => {'resize_calm_time'     => '5',
        'resize_down_by'       => '1',
        'resize_up_by'         => '1'},
      'alert_specific_params' => {'decision_threshold' => '51'}
    }
  end
  inputs do {
             "GCE_SERVICE_ACCOUNT" => join(["cred:","GCE_PLUGIN_ACCOUNT"]),
             "GCE_SERVICE_ACCOUNT_JSON" => join(["cred:","GCE_PLUGIN_PKJSON"]),
             "TARGET_POOL" => join(["text:",@elb_target_pool.name])
    }
  end
end

output "elb_address" do
  label " Address"
  category "GCE ELB"
  default_value @elb_address.address
  description "GCE ELB IP address."
end
