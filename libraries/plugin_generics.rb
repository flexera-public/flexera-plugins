name "Package: plugin_generics"
rs_ca_ver 20161221
short_description "Provides logging functionality for sending logs to audit entries in CM"
package "plugin_generics"
import "sys_log"

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Debug Report")
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end