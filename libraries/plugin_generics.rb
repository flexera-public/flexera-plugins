name "Package: plugin_generics"
rs_ca_ver 20161221
short_description "Provides generic functions for plugins"
long_description "Version: 1.3"
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

define handle_retries($task_label,$attempts, $max_attempts) do
  if $attempts <= $max_attempts
    sleep(10*to_n($attempts))
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Task: "+$task_label+" Attempt: "+ $attempts+" of " + $max_attempts)
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end