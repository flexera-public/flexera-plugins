name 'GCP Cloud DNS Record - Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - Cloud DNS - Test CAT - Record Only"
import "plugins/googledns"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
    like $googledns.google_project
    default "rightscale.com:services1"
end

parameter "dns_zone" do
    like $googledns.dns_zone
end

parameter "dns_name" do
    label "DNS Name"
    type "string"
    default "ss-plugin.com."
end

parameter "param_record_name" do
    type "string"
    label "record name"
    default "foobar"
end


##########################
##########################
#######  Outputs  ########
##########################
##########################


output "record_object" do
    label "Record Object"
    category "Record"
end

output "record_name" do
    label "Record Name"
    category "DNS Record"
end

output "record_rrdatas" do
    label "Record RRDatas"
    category "DNS Record"
end

output "record_type" do
    label "Record Type"
    category "DNS Record"
end

output "record_ttl" do
    label "Record TTL"
    category "DNS Record"
end 


##########################
##########################
####### Resources ########
##########################
##########################
    

resource "my_recordset", type: "clouddns.resourceRecordSet" do
    #managed_zone @my_zone.id 
    record do {
        "name" => join([$param_record_name, ".", $dns_name ]),
        "ttl" => 300,
        "type" => "A",
        "rrdatas" => [ "4.3.2.1"]
    } end

end

##########################
##########################
###### Operations ########
##########################
##########################


operation "get_record" do
    definition "get_record"
    output_mappings do {
        $record_object => $object
    } end
end

operation "delete_record" do
    definition "delete_record"
end

operation "launch" do
    definition "launch_handler"
    output_mappings do {
        $record_object => $object,
        $record_name => $name,
        $record_rrdatas => $rrdatas,
        $record_type => $type,
        $record_ttl => $ttl
    } end
end 


##########################
##########################
###### Definitions #######
##########################
##########################

define launch_handler(@my_recordset) return @my_recordset, $object, $rrdatas, $type, $ttl, $name do
    provision(@my_recordset)
    $object = to_s(to_object(@my_recordset))
    $rrdatas = to_s(@my_recordset.rrdatas)
    $type = @my_recordset.type
    $ttl = @my_recordset.ttl
    $name = @my_recordset.name
end 

define get_record(@my_recordset) return $object do
    call start_debugging()
    sub on_error: stop_debugging() do
        @my_recordset = @my_recordset.get()
        $object = to_s(to_object(@my_recordset))
    end
    call stop_debugging()
end

define delete_record(@my_recordset) do
    call start_debugging()
    $raw = to_object(@my_recordset)
    $fields = $raw["details"]
    call set_task_target(@@deployment)
    call summary(join(["Delete: ",$type]))
    call detail(join(["object: ", to_s($raw)]))
    call detail(join(["fields: ", $fields]))
    sub on_error: stop_debugging() do
        clouddns.resourceRecordSet.delete(record: $fields)
    end
    call stop_debugging()
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call detail($debug_report)
    $$debugging = false
  end
end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

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