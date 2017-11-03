name "Package: acl"
rs_ca_ver 20161221
short_description "Provides logging rudimentary acl functions for cats"
package "acl"

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
#  ------

# Append to the audit entry detail for this process

define find_user_href() return $user_href do
  $session_info = rs_cm.sessions.get(view: "whoami")
  $user_link = select($session_info[0]["links"], {rel: "user"})
  $user_href = $user_link[0]["href"]
end

define get_user_groups($user_href) return $groups do
    $user_id = last(split($user_href, '/'))
    $cloud_response = http_get(
        url: "https:/us-3.rightscale.com/grs/users/" + $user_id,
        headers: { "X_API_VERSION": "2.0" },
        cookies: $account_cookies
    )
    $clouds = $cloud_response["body"]
end

define check_user_permissions($group)
  call find_user_href() retrieve $user_href
  call get_user_groups($user_href) retrieve $groups
  if logic_not(contains?($groups,$group))
    raise "Unable to launch cat, you do not belong to the appropriate groups"
  end
end
