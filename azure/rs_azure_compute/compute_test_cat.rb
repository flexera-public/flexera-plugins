name 'Azure Compute Test CAT'
rs_ca_ver 20161221
short_description "Azure Compute - Test CAT"
import "sys_log"
import "plugins/rs_azure_compute"

parameter "subscription_id" do
  like $rs_azure_compute.subscription_id
end

parameter "vmSize" do
  label "VirtualMachine Sizes"
  type "string"
  allowed_values "Standard_F1","Standard_F2","Standard_F4","Standard_F8","Standard_F16"
  default "Standard_F1"
end

parameter "vmSize2" do
  label "VMS"
  type "string"
  description "json:{\"definition\":\"getSizes\", \"description\": \"Pick the vmSize\"}"
  operations "change_size"
end


permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

output "vm_ids" do
  label "VM ids"
end

output "vm_sizes" do
  label "Available VM Sizes"
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

resource "deployment_availability_group", type: "rs_azure_compute.availability_set" do
  name @@deployment.name
  resource_group @@deployment.name
  location "Central US"
  sku do {
    "name" => "Aligned"
  } end
  properties do {
      "platformUpdateDomainCount" => 5,
      "platformFaultDomainCount" => 3
  } end
end

resource "server1", type: "server" do
  name join(["server1-", last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
  server_template "RightLink 10.6.0 Linux Base"
  multi_cloud_image_href "/api/multi_cloud_images/423486003"
  network "ARM-CentralUS"
  subnets "default"
  instance_type $vmSize
  security_groups "Default"
  associate_public_ip_address true
  cloud_specific_attributes do {
    "availability_set" => @my_availability_group.name
  }
  end
end

resource "my_vm_extension", type: "rs_azure_compute.extensions" do
  name join(["easy-", last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  virtualMachineName @server1.name
  properties do {
    "publisher" => "Microsoft.OSTCExtensions",
    "type" => "CustomScriptForLinux",
    "typeHandlerVersion" => "1.5",
    "autoUpgradeMinorVersion" => true,
    "settings" => {
       "fileUris" => [ "https://s3.amazonaws.com/rightscale-services/scripts/easy.sh" ],
       "commandToExecute" => "sh easy.sh"
    }
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
    $vm_ids => $vms,
    $vm_sizes => $vmss
  } end
end

operation "change_size" do
  description "changes size"
  definition "supersize_me"
end

define launch_handler(@my_availability_group,@server1,@my_vm_extension,@deployment_availability_group) return @my_availability_group,@my_availability_group,@server1,@my_vm_extension,@deployment_availability_group,$vms,$vmss do
  call start_debugging()
  provision(@my_availability_group)
  provision(@server1)
  provision(@my_vm_extension)
  $object = to_object(@deployment_availability_group)
  $fields = $object["fields"]
  $name = $fields["name"]
  $resource_group = $fields["resource_group"]
  @deployment_ag = rs_azure_compute.availability_set.show(resource_group: $resource_group, name: $name)
  $vms = to_s(@my_availability_group.virtualmachines)
  $vms = $vms + to_s(@deployment_ag.virtualmachines)
  call sys_log.detail("vms:" + to_s($vms))
  @vm=rs_azure_compute.virtualmachine.show(resource_group: $resource_group, virtualMachineName: @server1.name)
  $vmss = @vm.vmSizes()
  call sys_log.detail("sizes:" + to_s($vmss))
  $vmss=to_s($vmss)
  $vm_object=to_object(@vm)
  $vm_fields=$vm_object["details"][0]
  $vm_fields["properties"]["diagnosticsProfile"]={}
  $vm_fields["properties"]["diagnosticsProfile"]["bootDiagnostics"]={}
  $vm_fields["properties"]["diagnosticsProfile"]["bootDiagnostics"]["enabled"] = true
  $vm_fields["properties"]["diagnosticsProfile"]["bootDiagnostics"]["storageUri"] = "https://dftestingdiag134.blob.core.windows.net"
  @vm.update($vm_fields)
  call stop_debugging()
end

define getSizes() return $values do
  call start_debugging()
  sub on_error: stop_debugging() do
    @vm=rs_azure_compute.virtualmachine.show(resource_group: @@deployment.name, virtualMachineName: join(["server1-", last(split(@@deployment.href, "/"))]))
    $$vmss = @vm.vmSizes()
  end
  call stop_debugging()
  call sys_log.detail("sizes:" + to_s($$vmss))
  $values=[]
  $values << "Standard_F1"
  foreach $size in $$vmss[0]["value"] do
    $values << $size["name"]
  end

end

define supersize_me(@server1,$vmSize) return @server1 do
  @vm=rs_azure_compute.virtualmachine.show(resource_group: @@deployment.name, virtualMachineName: @server1.name)
  $vm_object=to_object(@vm)
  $vm_fields=$vm_object["details"][0]
  $vm_fields["properties"]["hardwareProfile"]={}
  $vm_fields["properties"]["hardwareProfile"]["vmSize"] = $vmSize
  @vm.update($vm_fields)
  sleep(60)
  sleep_until(@server1.state == 'operational')
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