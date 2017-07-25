name 'Azure Compute Test CAT'
rs_ca_ver 20161221
short_description "Azure Compute - Test CAT"
import "sys_log"
import "plugins/rs_azure_compute"

parameter "subscription_id" do
  like $rs_azure_compute.subscription_id
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "my_availability_group", type: "rs_azure_compute.availability_set" do
  name @@deployment.name
  resource_group "rs-default-centralus"
  location "Central US"
  sku do {
    "name" => "Aligned"
  } end
  properties do {
      "platformUpdateDomainCount" => 5,
      "platformFaultDomainCount" => 3
  } end
end

resource "rs_testing", type: "rs_azure_compute.availability_set" do
  name "rs-testing"
  resource_group "rs-default-centralus"
  location "Central US"
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

define launch_handler(@rs_testing,$subscription_id) return @rs_testing,@vms,$vms do
  $object = to_object(@rs_testing)
  $fields = $object["fields"]
  call start_debugging()
  @rs_testing = rs_azure_compute.availability_set.get("href": "/subscriptions/"+$subscription_id+"/resourceGroups/"+$fields["resource_group"]+"/providers/Microsoft.Compute/availabilitySets/"+$fields["name"]+"?api-version=2016-04-30-preview")
  @vms = rs_azure_compute.virtualmachine.empty()
  $vms = @rs_testing.virtualmachines
  call sys_log.detail("vms:" + to_s($vms))
  foreach $vm in $vms do
    @vms = @vms + rs_azure_compute.virtualmachine.get("href": $vm["id"])
  end
  call stop_debugging()
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