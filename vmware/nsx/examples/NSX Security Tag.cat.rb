name 'NSX Security Tag'
short_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
An NSX Security Tag."
long_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
Create and manage an NSX Security Tag (experimental)."
type 'application'

rs_ca_ver 20161221

import 'sys_log'
import 'plugins/nsx'


###
# User Inputs
###
parameter 'nsx_security_tag_name' do
  label 'Name'
  description 'A name for the security tag.'
  category 'NSX Security Tag'
  type 'string'
  min_length 1
  default "nsx-plugin-st-"
end

resource 'nsx_security_tag', type: 'nsx.security_tag' do
  name $nsx_security_tag_name
  description 'My security tag description.'
end

###
# Outputs
###

output "list_st" do
  label "st count"
end

###
# Operations
###
operation 'list_sectags' do
  definition 'list_sts'
  output_mappings do{
    $list_st => $count
  }end
end

###
# Definitions
###

define list_sts() return $count do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("List")
  call start_debugging()
  @sgs = nsx.security_tag.list()
  call stop_debugging()
  call sys_log.detail(to_object(@sgs))
  $count = to_s(size(@sgs))
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
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end
