name "Package: acl"
rs_ca_ver 20161221
short_description "Provides logging rudimentary acl functions for cats"
package "acl"

########################################################
#  USAGE
#
#  This package provides a very rudimentary acl system for cats. 
#
#  EXAMPLE
#  -----
#  To define which groups can launch this cat, use the following code.
#  ```
#  import 'acl'
#  call acl.check_user_permissions("groupname")
#  ```
#
#  ------

# Append to the audit entry detail for this process
define get_account_href() return $account_href do
  $session = rs_cm.sessions.index(view: "whoami")
  $account_href = select($session[0]["links"], {"rel":"account"})[0]["href"]
end

# Finding the shard number for the current account
define find_shard() return $shard_number do
  call get_account_href() retrieve $account_href
  $account = rs_cm.get(href: $account_href)
  $shard_number = last(split(select($account[0]["links"], {"rel":"cluster"})[0]["href"],"/"))
end

define find_user_href() return $user_href do
  $session_info = rs_cm.sessions.get(view: "whoami")
  $user_link = select($session_info[0]["links"], {rel: "user"})
  $user_href = $user_link[0]["href"]
end

define get_user_groups($user_href) return $groups do
    $user_id = last(split($user_href, '/'))
    call find_shard() retrieve $shard_number
    $cloud_response = http_get(
        url: "https://us-" + $shard_number + ".rightscale.com/grs/users/" + $user_id + "?view=extended",
        headers: { "X_API_VERSION": "2.0" }
    )
    $body = $cloud_response["body"]
    $group_array = $body["groups"]
    $groups = []
    foreach $group in $group_array do
      $groups << $group["name"]
    end
end

define check_user_permissions($group) do
  call find_user_href() retrieve $user_href
  call get_user_groups($user_href) retrieve $groups
  if logic_not(contains?($groups,[$group]))
    raise "Unable to launch cat, you do not belong to the appropriate groups"
  end
end
