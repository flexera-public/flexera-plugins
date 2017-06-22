name 'GCP Cloud DNS Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - Cloud DNS - Test CAT"
import "plugins/googledns"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
    like $googledns.google_project
end

parameter "dns_zone" do
    label "DNS Managed Zone - Name"
    category "Managed Zone"
    type "string"
    min_length 1
end

parameter "param_dns_name" do
    label "DNS Managed Zone - DNS Name"
    category "Managed Zone"
    type "string"
    min_length 1
end

parameter "param_zone_desc" do
    label "DNS Managed Zone - Description"
    category "Managed Zone"
    type "string"
end

parameter "param_record_name" do
    type "string"
    label "record name"
end

parameter "param_zone_id" do
    type "string"
    label "zone id"
end 

##########################
##########################
#######  Outputs  ########
##########################
##########################

output "zone_creationTime" do
    label "Creation Time"
    category "DNS Managed Zone"
    default_value @my_zone.creationTime 
end

output "zone_description" do
    label "Description"
    category "DNS Managed Zone"
    default_value @my_zone.description
end

output "zone_dnsName" do
    label "DNS Name"
    category "DNS Managed Zone"
    default_value @my_zone.dnsName
end

output "zone_id" do
    label "ID"
    category "DNS Managed Zone"
    default_value @my_zone.id 
end 

output "kind" do
    label "Kind"
    category "DNS Managed Zone"
    default_value @my_zone.kind
end

output "zone_name" do
    label "Name"
    category "DNS Managed Zone"
    default_value @my_zone.name
end

output "zone_nameservers" do 
    label "Nameservers"
    category "DNS Managed Zone"
end

output "proj_kind" do
    label "Kind"
    category "Project"
end

output "proj_number" do
    label "Number"
    category "Project"
end

output "proj_id" do
    label "ID"
    category "Project"
end

output "proj_zone_quota" do
    label "Managed Zones - Quota"
    category "Project"
end 

output "proj_records_per_rrset" do
    label "Resource Records Per Resource Record Sets - Quota"
    category "Project"
end

output "proj_add_per_change" do
    label "Resource Record Sets Additions Per Change - Quota"
    category "Project"
end

output "proj_del_per_change" do
    label "Resource Record Sets Deletions Per Change - Quota"
    category "Project"
end

output "proj_rrset_per_zone" do
    label "Resource Record Sets Per Managed Zone - Quota"
    category "Project"
end

output "proj_data_size_per_change" do
    label "Resource Record Data Size Per Change - Quota"
    category "Project"
end

output "record_object" do
    label "Record Object"
    category "Record"
end

output "link_test_out" do
    label "link test - zone id"
end

##########################
##########################
####### Resources ########
##########################
##########################
    
resource "my_zone", type: "clouddns.managedZone" do
    name $dns_zone
    description $param_zone_desc
    dns_name $param_dns_name
end

resource "my_recordset", type: "clouddns.resourceRecordSet" do
    #managed_zone @my_zone.id 
    record do {
        "name" => join(["foobar.", $param_dns_name ]),
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

operation "launch" do
    definition "launch_handler"
    output_mappings do {
        $zone_nameservers => $nameservers 
    } end
end 

operation "terminate" do
    definition "terminate"
end

operation "get_dns_quotas" do
    definition "get_project"
    output_mappings do {
        $proj_kind => $kind,
        $proj_number => $number,
        $proj_id => $id,
        $proj_zone_quota => $zone_quota,
        $proj_records_per_rrset => $records_per_rrset,
        $proj_add_per_change => $add_per_change,
        $proj_del_per_change => $del_per_change,
        $proj_rrset_per_zone => $rrset_per_zone,
        $proj_data_size_per_change => $data_size_per_change
    } end
end 

operation "get_record" do
    definition "get_record"
    output_mappings do {
        $record_object => $object
    } end
end

operation "delete_record" do
    definition "delete_record"
end

operation "link_test" do
    definition "link_test"
    output_mappings do {
        $link_test_out => $object
    } end
end 

##########################
##########################
###### Definitions #######
##########################
##########################

define launch_handler(@my_zone, @my_recordset) return @my_zone, @my_recordset, $nameservers do
    provision(@my_zone)
    $nameservers = to_s(@my_zone.nameServers)
    provision(@my_recordset)
end 

define terminate(@my_zone, @my_recordset) do
    delete(@my_recordset)
    delete(@my_zone)
end 

define get_project(@my_zone) return $kind,$number,$id,$zone_quota,$records_per_rrset,$add_per_change,$del_per_change,$rrset_per_zone,$data_size_per_change do
    @project = @my_zone.project()
    $kind = @project.kind
    $number = to_s(@project.number)
    $id = @project.id
    $zone_quota = to_s(@project.managedZones_quota)
    $records_per_rrset = to_s(@project.resourceRecordsPerRrset_quota)
    $add_per_change = to_s(@project.rrsetAdditionsPerChange_quota)
    $del_per_change = to_s(@project.rrsetDeletionsPerChange_quota)
    $rrset_per_zone = to_s(@project.rrsetsPerManagedZone_quota)
    $data_size_per_change = to_s(@project.totalRrdataSizePerChange_quota)
end 

define get_record($param_record_name,$param_zone_id) return $object do
    @my_recordset = clouddns.resourceRecordSet.list(name: $param_record_name, managed_zone: $param_zone_id)
    $object = to_s(to_object(@my_recordset))
end

define delete_record(@my_recordset) do
    $raw = to_object(@my_recordset)
    $fields = $raw["fields"]
    $record = $fields["record"]
    $zone = $fields["managed_zone"]
    call set_task_target(@@deployment)
    call summary(join(["Delete: ",$type]))
    call detail(join(["fields: ", $fields]))
    call detail(join(["record: ", $record]))
    call detail(join(["zone: ", $zone]))
    sub on_error: stop_debugging() do
        clouddns.resourceRecordSet.delete(managed_zone: $zone, record: $record)
    end
end

define link_test(@my_recordset) return $output do
    @zone = @my_recordset.managedZone()
    $output = @zone.id
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