name 'NSX Distributed Firewall'
short_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
An NSX Distributed Firewall."
long_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
Create and manage an NSX Distributed Firewall (experimental)."
type 'application'

rs_ca_ver 20161221

import 'sys_log'
import 'plugins/nsx'

###
# User Inputs
###
parameter 'nsx_firewall_layer2section_name' do
  label 'Name'
  description 'A name for the layer2section.'
  category 'NSX Firewall Layer2Section'
  type 'string'
  min_length 1
  default "nsx-plugin-fw-l2-"
end

resource 'nsx_fw_l2section', type: 'nsx.firewall_layer2section' do
  section do {
    '-name' => $nsx_firewall_layer2section_name
  } end
end

###
# Outputs
###

# output "firewallConfiguration" do
#   label "Firewall Configuraiton"
# end

###
# Operations
###
# operation '' do
#   definition 'list_sts'
#   output_mappings do{
#     $list_st => $count
#   }end
# end
operation 'getFirewallConfiguration' do
  definition 'getFWconfig'
end

operation 'listFirewallConfiguration' do
  definition 'getFWconfig'
end

###
# definitions
###

define getFWconfig() do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Get Firewall Config")
  call start_debugging()
  @firewall = nsx.firewall.get()
  call stop_debugging()
  call sys_log.detail(to_object(@firewall))
  call sys_log.detail(@firewall.firewallConfiguration)
end

# define list_sts() return $count do
#   call sys_log.set_task_target(@@deployment)
#   call sys_log.summary("List")
#   call start_debugging()
#   @sgs = nsx.security_tag.list()
#   call stop_debugging()
#   call sys_log.detail(to_object(@sgs))
#   $count = to_s(size(@sgs))
# end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end
