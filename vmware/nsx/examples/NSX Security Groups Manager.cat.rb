name 'NSX Security Groups Manager'
short_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
Manage NSX Security Groups."
long_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
Manage NSX Security Groups (experimental)."
type 'application'

rs_ca_ver 20161221

import 'plugins/nsx'
import 'sys_log'

###
# User Inputs
###

###
# Local Definitions
###
define audit_log($summary, $details) do
  rs_cm.audit_entries.create(
    notify: "None",
    audit_entry: {
      auditee_href: @@deployment,
      summary: $summary,
      detail: $details
    }
  )
end

define skip_not_found_error() do
  if $_error["message"] =~ "/not found/i"
    log_info($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "skip"
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
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end

define list_nsx_security_groups() on_error: stop_debugging() do
  call start_debugging()

  call sys_log.set_task_target(@@deployment)

  $fields = {}
  $security_groups = nsx.securitygroup.list($fields)
  call audit_log('nsx security groups', to_s($security_groups))

  call stop_debugging()
end

###
# Outputs
###
# todo

###
# Operations
###
operation 'list_nsx_security_groups' do
  description 'Lists all NSX Security Groups'
  definition 'list_nsx_security_groups'
  label 'List NSX Security Groups'
end
