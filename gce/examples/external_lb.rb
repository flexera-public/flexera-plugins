name "Google External LB Implementation"
rs_ca_ver 20161221
short_description "Sample Google External LB Implementation"
type 'application'

import "sys_log"
import "plugins/gce"

parameter "gce_project" do
  like $gce.gce_project
  default "rightscale.com:services1"
end

parameter "lb_name" do
  type "string"
  label "LB Name"
  category "GCE External LB"
  default "gce-plugin"
  allowed_pattern "^[0-9a-z\-]+$"
end

parameter "lb_region" do
  type "string"
  label "LB Region"
  category "GCE External LB"
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
  ipAddress @elb_address.name
  loadBalancingScheme "EXTERNAL"
  portRange "80-80"
  target @elb_target_pool.selfLink
end

# resource "server_array", type: "rs_cm.server" do
# end

output "elb_address" do
  label " Address"
  category "GCE ELB"
  default_value @elb_address.address
  description "GCE ELB IP address."
end
