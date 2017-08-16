name 'Azure Redis Test CAT'
rs_ca_ver 20161221
short_description "Azure MySQL Database Service - Test CAT"
import "sys_log"
import "plugins/rs_azure_redis"

parameter "subscription_id" do
  like $rs_azure_redis.subscription_id
end

output "firewall_rules" do
  label "firewall_rules"
  category "Firewall Rules"
  default_value $firewall_rules_link_output
  description "firewall_rules"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "cache1", type: "rs_azure_redis.cache" do
  name join(["cache1-", last(split(@@deployment.href, "/"))])
  resource_group "CCtestresourcegroup"
  location "North Central US"
  properties do {
    "sku": {
      "name": "Premium",
      "family": "P",
      "capacity": 1
    },
    "enableNonSslPort": true,
    "shardCount": 1,
    "redisConfiguration": {
      "maxclients": "7500",
      "maxmemory-reserved": "200",
      "maxfragmentationmemory-reserved": "300",
      "maxmemory-delta": "200"
    }
  } end
  tags do {
      "ElasticCache" => "1"
  } end
end

resource "firewall_rule", type: "rs_azure_redis.firewall_rule" do
  name "samplefirewallrule"
  resource_group "CCtestresourcegroup"
  server_name @cache1.name
  properties do {
    "startIP" => "192.168.1.1",
    "endIP" => "192.168.1.254"
  } end
end

resource "patch_schedule", type: "rs_azure_redis.patch_schedule" do
  resource_group "CCtestresourcegroup"
  server_name @cache1.name
  properties do {
    "scheduleEntries": [
      {
        "dayOfWeek": "Monday",
        "startHourUtc": 12,
        "maintenanceWindow": "PT6H"
      },
      {
        "dayOfWeek": "Tuesday",
        "startHourUtc": 12
      }
    ]
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
  $firewall_rules => $firewall_rules_link_output
 } end
end

operation "terminate" do
  description "terminates the application"
  definition "terminate_handler"
end

define launch_handler(@cache1,@firewall_rule,@patch_schedule) return @cache1,@firewall_rule,@patch_schedule,$firewall_rules_link_output do
  provision(@cache1)
  provision(@firewall_rule)
  provision(@patch_schedule)
  call start_debugging()
  sub on_error: skip, timeout: 2m do
    call sys_log.detail("getting firewall link")
    @firewall_rules = @cache1.firewall_rules() 
    $firewall_rules_link_output  = to_s(to_object(@firewall_rules))
  end
  call stop_debugging()
end

define terminate_handler(@cache1,@firewall_rule,@patch_schedule) do
  sub on_error: skip do
    delete(@cache1)
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
