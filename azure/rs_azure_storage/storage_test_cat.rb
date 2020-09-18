name 'Azure Storage Test CAT'
rs_ca_ver 20161221
short_description "Azure Storage - Test CAT"
import "sys_log"
import "plugins/rs_azure_storage"

parameter "subscription_id" do
  like $rs_azure_storage.subscription_id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

output "storage_keys" do
  label "created Storage Keys"
end

output "storage_account_key_1" do
  label "Storage Account Key 1"
end

output "storage_account_endpoints" do
  label "storage_account_endpoints"
end

output "pg_storage_keys" do
  label "get Storage Keys"
end

resource "my_placement_group", type: "placement_group" do
  name join(["mypg", last(split(@@deployment.href, "/"))])
  description "test placement group"
  cloud "AzureRM Central US"
  cloud_specific_attributes do {
    "account_type" => "Standard_LRS"
  } end
end

resource "my_storage_account", type: "rs_azure_storage.storage_account" do
  name join(["mysa", last(split(@@deployment.href, "/"))])
  resource_group "rs-default-centralus"
  location "Central US"
  kind "BlobStorage"
  sku do {
    "name" => "Standard_LRS",
    "tier" => "Standard"
  } end
  properties do {
    "accessTier" => "Hot",
    "supportsHttpsTrafficOnly" => false
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
    $storage_keys => $s_keys,
    $pg_storage_keys => $s_pgstkeys,
    $storage_account_key_1 => $stak1,
    $storage_account_endpoints => $sae
  } end
end

define launch_handler(@my_storage_account,@my_placement_group) return @my_storage_account,$s_keys,$stak1,$sae,$s_pgstkeys do
  sub on_error: stop_debugging() do
    call start_debugging()
    provision(@my_storage_account)
    provision(@my_placement_group)
    $keys = @my_storage_account.list_keys()
    $s_keys = to_s($keys)
    call sys_log.detail("keys:" + $s_keys)
    $stak1 = $keys[0]["keys"][0]["value"]
    $sae = to_s(@my_storage_account.primaryEndpoints)
    call stop_debugging()
    call start_debugging()
    @pg_st_acct = rs_azure_storage.storage_account.show(name: @my_placement_group.name, resource_group: @@deployment.name )
    $pgstkeys = @pg_st_acct.list_keys()
    $s_pgstkeys = to_s($pgstkeys)
    call sys_log.detail("pgst:" + $s_pgstkeys)
    call stop_debugging()
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