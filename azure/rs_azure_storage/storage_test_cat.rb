name 'Azure Storage Test CAT'
rs_ca_ver 20161221
short_description "Azure Storage - Test CAT"
import "sys_log"
import "plugins/rs_azure_storage"

parameter "subscription_id" do
  like $rs_azure_storage.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

output "storage_keys" do
  label "created Storage Keys"
end

output "df_storage_keys" do
  label "get Storage Keys"
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
    $df_storage_keys => $s_dfstkeys
  } end
end

define launch_handler(@my_storage_account) return @my_storage_account,$s_keys,$s_dfstkeys do
  sub on_error: stop_debugging_and_raise() do
    call start_debugging()
    provision(@my_storage_account)
    $keys = @my_storage_account.list_keys()
    $s_keys = to_s($keys)
    call sys_log.detail("keys:" + $s_keys)
    call stop_debugging()
    call start_debugging()
    @df_st_acct = rs_azure_storage.storage_account.show(name: "dftestingdiag134", resource_group: "DF-Testing" )
    $dfstkeys = @df_st_acct.list_keys()
    $s_dfstkeys = to_s($dfstkeys)
    call sys_log.detail("dfst:" + $s_dfstkeys)
    call stop_debugging()
  end
end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging_and_raise() do
  call stop_debugging()
  raise $_errors
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end