name 'Azure Load Balancer - Test CAT'
rs_ca_ver 20161221
short_description "Azure Load Balancer - Test CAT"
import "sys_log"
import "plugins/rs_azure_networking"

parameter "subscription_id" do
  like $rs_azure_networking.subscription_id
end

output "bu_pool" do
  label "Backend pool"
end

output "lb_ip1" do
  label "Load Balancer IP"
end

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

resource "lb_ip", type: "rs_cm.ip_address" do
  name @@deployment.name
  cloud "AzureRM Central US"
  network "ARM-CentralUS"
end

resource "my_pub_lb", type: "rs_azure_lb.load_balancer" do
  name join(["my-pub-lb-", last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  frontendIPConfigurations do [
    {
     "name" => "ip1",
     "properties" => {
        "publicIPAddress" => {
          "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Network/publicIPAddresses/",@@deployment.name])
        }
      }
    }
  ] end

  backendAddressPools do [
    {
      "name" => "pool1"
    }
  ] end

  loadBalancingRules do [
    {
      "name"=> "HTTP-Traffic",
      "properties" => {
         "frontendIPConfiguration" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/frontendIPConfigurations/ip1"])
         },
         "backendAddressPool" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/backendAddressPools/pool1"])
         },
         "protocol" => "Tcp",
         "frontendPort" => 80,
         "backendPort" => 80,
         "probe" => {
            "id" => join(["/subscriptions/",$subscription_id,"/resourceGroups/",@@deployment.name,"/providers/Microsoft.Network/loadBalancers/",join(["my-pub-lb-", last(split(@@deployment.href, "/"))]),"/probes/probe1"])
         },
         "enableFloatingIP" => false,
         "idleTimeoutInMinutes" => 4,
         "loadDistribution" => "Default"
      }
    }
  ] end

  probes do [
    {
      "name" =>  "probe1",
      "properties" => {
        "protocol" =>  "Http",
        "port" =>  80,
        "requestPath" =>  "/",
        "intervalInSeconds" =>  5,
        "numberOfProbes" =>  16
      }
    }
  ] end
end

resource "server1", type: "server" do
  name join(["server1-", last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
  server_template "RightLink 10.6.0 Linux Base"
  multi_cloud_image_href "/api/multi_cloud_images/423486003"
  network "ARM-CentralUS"
  subnets "default"
  instance_type "Standard_F1"
  security_groups "Default"
  associate_public_ip_address true
  cloud_specific_attributes do {
    "availability_set" => join(["availability-set_", last(split(@@deployment.href, "/"))]),
    "root_volume_type_uid" => "Standard_LRS"
  } end
end

resource "server2", type: "server" do
  name join(["server2-", last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
  server_template "RightLink 10.6.0 Linux Base"
  multi_cloud_image_href "/api/multi_cloud_images/423486003"
  network "ARM-CentralUS"
  subnets "default"
  instance_type "Standard_F1"
  security_groups "Default"
  associate_public_ip_address true
  cloud_specific_attributes do {
    "availability_set" => join(["availability-set_", last(split(@@deployment.href, "/"))]),
    "root_volume_type_uid" => "Standard_LRS"
  } end
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
  output_mappings do {
    $bu_pool => $pool_id,
    $lb_ip1 => $lb_ip
  } end
end

operation "terminate" do 
  definition "terminate"
end

define launch_handler(@server1,@server2,@lb_ip,@my_pub_lb,$subscription_id) return @server1,@server2,@lb_ip,@my_pub_lb,$pool_id,$lb_ip do
  task_label("Provisioning Server")
  concurrent return @server1, @server2 do
    provision(@server1)
    provision(@server2)
  end
  task_label("Provisioning LB IP")
  provision(@lb_ip)
  task_label("Provisioning Load Balancer")
  provision(@my_pub_lb)
  task_label("Installing Apache")
  concurrent return @server1, @server2 do
    call run_rightscript_by_name(@server1.current_instance(), 'install_apache.sh')
    call run_rightscript_by_name(@server2.current_instance(), 'install_apache.sh')
  end
  task_label("Adding Server to LB")
  call add_to_lb(@server1,@my_pub_lb)
  call add_to_lb(@server2,@my_pub_lb)
  $pool_id = @my_pub_lb.backendAddressPools[0]["id"]
  $lb_ip = @lb_ip.address
end

define add_to_lb(@server,@my_pub_lb) return @server,@my_target_nic do
  sub on_error: stop_debugging() do
    call start_debugging()
    @nics = rs_azure_networking.interface.list(resource_group: @@deployment.name)
    call stop_debugging()
    call sys_log.detail("all nics:"+to_s(@nics))
    @my_target_nic = rs_azure_networking.interface.empty()
    foreach @nic in @nics do
      call sys_log.detail("server name:"+to_s(@server.name))
      call start_debugging()
      @nic.get()
      call stop_debugging()
      call sys_log.detail("nic:"+to_s(@nic))
      call sys_log.detail("nic_name:" + @nic.name)
      if @nic.name =~ @server.name
        @my_target_nic = @nic
        call sys_log.detail("target nic: true")
      else
        call sys_log.detail("target nic: false")
      end
    end
    $object = to_object(@my_target_nic)
    call sys_log.detail("target nic object:" + to_s($object)+"\n")
    $fields = $object["details"]
    call sys_log.detail("target nic fields:" + to_s($fields) + "\n")
    $nic = $fields[0]
    call sys_log.detail("target nic:" + to_s($nic))
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"] = []
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0] = {}
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0]["id"] = @my_pub_lb.backendAddressPools[0]["id"]
    call sys_log.detail("updated target nic:" + to_s($nic))
    call start_debugging()
    @updated_nic = @my_target_nic.update($nic)
    call stop_debugging()
  end
end

define run_rightscript_by_name(@target, $script_name) do
  @script = rs_cm.right_scripts.index(latest_only: true, filter: [join(["name==", $script_name])])
  @task = @target.run_executable(right_script_href: @script.href )
  sleep_until(@task.summary =~ "^(Completed|Aborted)")
  if @task.summary =~ "Aborted"
    raise "Failed to run " + $script_name
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

define terminate(@server1,@server2,@lb_ip,@my_pub_lb) return @server1,@server2,@lb_ip,@my_pub_lb do
  delete(@server1)
  delete(@server2)
  delete(@my_pub_lb)
  delete(@lb_ip)
end
