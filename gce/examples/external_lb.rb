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
  #resource_pool @gce
  region $lb_region
  name join([$lb_name,"-ip"])
  description join([$lb_name,"-ip"])
end

resource "elb_health", type: "gce.httpHealthCheck" do
  #resource_pool @gce
  name join([$lb_name,"-health-check"])
  description  join([$lb_name,"-health-check"])
end

resource "elb_target_pool", type: "gce.targetPool" do
  #resource_pool @gce
  region $lb_region
  name join([$lb_name,"-target-pool"])
  description join([$lb_name,"-target-pool"])
  healthChecks @elb_health.selfLink
end

resource "elb_forwarding_rule", type: "gce.forwardingRule" do
  #resource_pool @gce
  region $lb_region
  name join([$lb_name,"-forwarding-rule"])
  description join([$lb_name,"-forwarding-rule"])
  ipProtocol "TCP"
  ipAddress @elb_address.selfLink
  loadBalancingScheme "EXTERNAL"
  portRange "80"
  target @elb_target_pool.selfLink
end

output "elb_address" do
  label " Address"
  category "GCE ELB"
  default_value @elb_address.address
  description "GCE ELB IP address."
end

# operation "launch" do
#   definition "launch"
# end

# operation "terminate" do
#   definition "terminate"
# end

# define launch(@elb_address) return @elb_address do
# #define launch(@elb_address,@elb_health,@elb_target_pool,@elb_forwarding_rule) return @elb_address,@elb_health,@elb_target_pool,@elb_forwarding_rule do
#   call sys_log.set_task_target(@@deployment)
#   call sys_log.summary("Launch")

#   call sys_log.detail("Create Address")
#   call sys_log.detail(to_object(@elb_address))
#   provision(@elb_address)

#   call sys_log.set_task_target(@@deployment)
#   call sys_log.summary("Address List")
#   $addresses = gce.address.list({region: "us-east1"})
#   @addresses = gce.address.list({region: "us-east1"})
#   call sys_log.detail($addresses)
#   call sys_log.detail(to_object(@addresses))
#   provision(@elb_health)
#   provision(@elb_target_pool)
#   provision(@elb_forwarding_rule)
  
# end

define terminate(@elb_address,@elb_health,@elb_target_pool,@elb_forwarding_rule) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Terminate")

  call sys_log.detail("Delete Health")
  call sys_log.detail(to_object(@elb_health))
  delete(@elb_health)
  
  call sys_log.detail("Delete Forwarding Rule")
  call sys_log.detail(to_object(@elb_forwarding_rule))
  delete(@elb_forwarding_rule)

  call sys_log.detail("Delete Address")
  call sys_log.detail(to_object(@elb_address))
  delete(@elb_address)

  call sys_log.detail("Delete TargetPool")
  call sys_log.detail(to_object(@elb_target_pool))
  delete(@elb_target_pool)
end
