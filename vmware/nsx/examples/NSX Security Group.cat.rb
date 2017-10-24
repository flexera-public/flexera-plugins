name 'NSX Security Group'
short_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
An NSX Security Group."
long_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
Create and manage an NSX Security Group (experimental)."
type 'application'

rs_ca_ver 20161221

import 'sys_log'
import 'plugins/nsx'


###
# User Inputs
###
parameter 'nsx_security_group_name' do
  label 'Name'
  description 'A name for the security group.'
  category 'NSX Security Group'
  type 'string'
  min_length 1
  default "nsx-plugin-sg-"
end

# parameter 'nsx_wstunnel' do
#   like $nsx.nsx_wstunnel
# end

#parameter 'nsx_user' do
#  label 'Username'
#  description 'The NSX user name.'
#  category 'NSX Endpoint'
#  type 'string'
#  min_length
  # MUST REMOVE!
#  default 'admin'
#end

#parameter 'nsx_password' do
#  label 'Password'
#  description "The NSX user's password."
#  category 'NSX Endpoint'
#  type 'string'
#  min_length 1
#  # MUST REMOVE!
#  default 'P@ssw0rdP@ssw0rd'
#end

resource 'nsx_security_group', type: 'nsx.security_group' do
  name $nsx_security_group_name
  description 'My security group description.'
end

###
# Outputs
###

output "list_sg" do
  label "sg count"
end

###
# Operations
###
operation 'list_secgroups' do
  definition 'list_sgs'
  output_mappings do{
    $list_sg => $count
  }end
end

###
# Definitions
###

define list_sgs() return $count do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("List")
  call start_debugging()
  @sgs = nsx.security_group.list()
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
