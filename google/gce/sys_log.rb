name "Package: sys_log"
rs_ca_ver 20161221
short_description "Provides logging functionality for sending logs to audit entries in CM"
package "sys_log"

########################################################
#  USAGE
#
#  This package provides log functions to log data to audit entries. You can use the
#  `summary` definition to set the audit summary and the `detail` definition to add to
#  the audit detail.
#
#  Before using either definition, you can optionally call `set_task_target` to specify which
#  resource in CM you want the audits on. If you do not call this definition, the audits will be
#  logged to the Deployment if this is used in a CloudApp in SS, or to the account if this is
#  used outside of a CloudApp.
#
#  Child tasks can optionally have their own target set, for example if you have concurrent tasks
#  that are operating on separate resource, you might want to have audits on those specific resources.
#  Any child task that does not have its own custom target will use the target of the root task.
#
#  EXAMPLE
#  -----
#  # Optionally you can set your own audit target. If you don't, it will default to the deployment (if
#  #  this is running in a CloudApp, or to the account if running outside of SS
#  @my_server = rs_cm.get(href: "/api/servers/1234")
#  call sys_log.set_task_target(@my_server)
#
#  # Set the summary name for the audit
#  call sys_log.summary("Audit summary")
#
#  # Add some content to the audit entry
#  call sys_log.detail("Some detail to append")
#  call sys_log.detail("More content for the detail")
#
#  # Change the summary of the audit
#  call sys_log.summary("Changed summary")
#
#  ------

# Append to the audit entry detail for this process
define detail($detail) do
  # Make sure globals are initialized
  call init_globals()

  # If there is no audit entry with this task name, go figure it out
  if $$audits[task_name()] == null
    call create_audit_for_task({})
  end

  # Append the audit detail
  @audit = $$audits[task_name()]
  @audit.append(detail: strftime(now(), "%Y/%m/%d %H:%M:%S +0000") + ": " + to_s($detail) + "\n")
end

# Update the audit entry summary for this process
define summary($status) do
  # Make sure globals are initialized
  call init_globals()

  # If there is no audit entry with this task name, go figure it out
  if $$audits[task_name()] == null
    call create_audit_for_task({})
  end

  # Change the audit summary
  @audit = $$audits[task_name()]
  @audit.update(audit_entry: {summary: $status})
end

# Set the audit target for the current task. Can change to a new target
#  during a task, in which case a *new audit* will be created with that
#  target and used
define set_task_target(@resource) do
  # Make sure globals are initialized
  call init_globals()

  # Set the audit entry target for this task to the href of the resource
  $$audit_targets[task_name()] = @resource.href

  # Clear the audit for this task
  $$audits[task_name()] = null
end

########################################################################
### PRIVATE - DO NOT CALL DIRECTLY
########################################################################

# Ensure globals are initialized
define init_globals() do
  if $$audit_targets == null
    $$audit_targets = {}
  end
  if $$audits == null
    $$audits = {}
  end
end

# Used to setup the audit entry - should not be called directly, but rather through
#  sys_log_summary or sys_log_detail
define create_audit_for_task($params) do

  if $$audits[task_name()] == null

    # Set some defaults so that calling either sys_log_detail or sys_log_summary first
    #  works fine
    $default_params = {
      detail: "",
      summary: "Initial audit from task: " + task_name()
    }
    $params = $params + $default_params

    # First check to make sure there is a root target. If not, create one. If the user didn't
    #  specify a root target, try @@deployment (if we're in a CloudApp), else use the account
    #  as the root target
    if $$audits["/root"] == null
      if $$audit_targets["/root"] == null
        # Try to use @@deployment if it's set (then it's a CloudApp). If it doesn't work,
        #  just skip the error and use the acct
        sub on_error: skip do
          $$audit_targets["/root"] = @@deployment.href
        end

        # If that didn't work, use the account
        if $$audit_targets["/root"] == null
          # This is a bit strange, but for some reason you can't put this into a reference
          #  and follow the `account()` link, so do it with json instead
          $session_info = rs_cm.sessions.get(view: "whoami")
          $acct_link = select($session_info[0]["links"], {rel: "account"})
          $$audit_targets["/root"] = $acct_link[0]["href"]
        end
      end
    end

    # If a custom task target is set for this task, create the audit for it. Else
    #  just use the root audit
    if $$audit_targets[task_name()] != null
      # Create the audit entry for this task
      $$audits[task_name()] = rs_cm.audit_entries.create(
        notify: "None",
        audit_entry: {
          auditee_href: $$audit_targets[task_name()],
          summary: $params["summary"],
          detail: to_s($params["detail"]) + "\n"
        }
      )
    else
      $$audits[task_name()] = $$audits["/root"]
    end
  else
    # Since set_task_target now nullifies the audit object, this code is probably NEVER called anymore

    # Make sure the audit target is current. If not, create a new audit for this target
    $current_href = select( to_object(@@audit)["details"][0]["links"], {"rel":"auditee"})[0]["href"]
    if $current_href != $$audit_targets[task_name()]
      # Create the audit entry for this task
      $$audits[task_name()] = rs_cm.audit_entries.create(
        notify: "None",
        audit_entry: {
          auditee_href: $$audit_targets[task_name()],
          summary: $params["summary"],
          detail: to_s($params["detail"]) + "\n"
        }
      )
    end
  end
end

##### Tests
# Not really working right now...


define test1_master() do
  call test_root_detail()
  call test_root_summary()
  call test_root_set_task()
  call test_child_detail()
  call test_child_summary()
  call test_child_set_task_first()
end


define test_root_detail() do
  call detail("Detail message")
  $task = "/root"

  assert  size($$audit_targets) == 1 && keys($$audit_targets)[0] == "/root" && $$audit_targets["/root"] =~ "/api/accounts/"
  assert  $$audits[$task] != null
  assert  $$audits[$task]["namespace"] == "rs_cm" && $$audits[$task]["type"] == "audit_entries"
  assert  size($$audits[$task]["hrefs"]) > 0 && $$audits[$task]["hrefs"] =~ "^/api/audit_entries"
  @audit = $$audits[$task]
  $detail = @audit.detail()
  assert  $detail[0] =~ "Detail message"
end
define test_root_summary() do
  call summary("Summary message")
  $task = "/root"

  assert  size($$audit_targets) == 1 && keys($$audit_targets)[0] == "/root" && $$audit_targets["/root"] =~ "/api/accounts/"
  assert  $$audits[$task] != null
  assert  $$audits[$task]["namespace"] == "rs_cm" && $$audits[$task]["type"] == "audit_entries"
  assert  size($$audits[$task]["hrefs"]) > 0 && $$audits[$task]["hrefs"] =~ "^/api/audit_entries"
  @audit = $$audits[$task]
  $summary = @audit.summary
  assert  $summary =~ "Summary message"
end


define test_root_set_task() do
  @d = rs_cm.deployments.create(deployment: {name: "test-"+uuid()})

  call set_task_target(@d)
  $task = "/root"

  assert  size($$audit_targets) == 1 && keys($$audit_targets)[0] == "/root" && $$audit_targets["/root"] == @d.href
  call detail("Detail message")
  assert  $$audits[$task] != null
  @audit = $$audits[$task]
  $detail = @audit.detail()
  assert  $detail[0] =~ "Detail message"
  # Clean up the deployment
  @d.destroy()
end

define test2_root_set_task_no_audit() do
  @d = rs_cm.deployments.create(deployment: {name: "test-"+uuid()})

  call set_task_target(@d)

  assert  size($$audit_targets) == 1 && keys($$audit_targets)[0] == "/root" && $$audit_targets["/root"] == @d.href
  # also make sure an audit isn't created yet
  assert  $$audits[$task] == null
  # Clean up the deployment
  @d.destroy()
end


define test_child_detail() do
  # Create a new task
  concurrent do
    sub do
      $size_audit_targets = size($$audit_targets)
      $task = task_name()

      call detail("Detail message")

      # audit targets shouldn't have been updated
      assert  size($$audit_targets) == $size_audit_targets
      # but audit should have been set to what's in "/root"
      assert  $$audits[$task] != null
      assert  $$audits[$task] == $$audits["/root"]
      @audit = $$audits[$task]
      $detail = @audit.detail()
      assert  $detail[0] =~ "Detail message"
      #
    end
  end
end
define test_child_summary() do
  # Create a new task
  concurrent do
    sub do
      $size_audit_targets = size($$audit_targets)
      $task = task_name()

      call summary("Summary message")

      # audit targets shouldn't have been updated
      assert  size($$audit_targets) == $size_audit_targets
      # but audit should have been set to what's in "/root"
      assert  $$audits[$task] != null
      assert  $$audits[$task] == $$audits["/root"]
      @audit = $$audits[$task]
      $summary = @audit.summary
      assert  $summary =~ "Summary message"
      #
    end
  end
end
define test_child_set_task_first() do
  # Create a new task
  concurrent do
    sub do
      @d = rs_cm.deployments.create(deployment: {name: "test-"+uuid()})
      $size_audit_targets = size($$audit_targets)
      $task = task_name()

      call set_task_target(@d)
      call detail("Detail message")

      assert  size($$audit_targets) == ($size_audit_targets + 1) && $$audit_targets[$task] != null && $$audit_targets[$task] == @d.href
      assert  $$audits[$task] != null
      assert  $$audits[$task] != $$audits["/root"]
      @audit = $$audits[$task]

      $detail = @audit.detail()
      assert  $detail[0] =~ "Detail message"
      # Clean up the deployment
      @d.destroy()
    end
  end
end
define test_child_set_task_summary() do
end

define change_task() do
end
