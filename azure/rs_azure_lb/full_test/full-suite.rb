name 'Azure Full Suite'
rs_ca_ver 20161221
short_description "Azure Full Suite - Test CAT"
import "sys_log"
import "plugins/rs_azure_networking_plugin"

parameter "subscription_id" do
  like $rs_azure_networking_plugin.subscription_id
  default "8beb7791-9302-4ae4-97b4-afd482aadc59"
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
         "enableFloatingIP" => true,
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
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

operation "add_to_lb" do
  description "adds to lb"
  definition "add_to_lb"
end

define launch_handler(@server1,@lb_ip,@my_pub_lb,$subscription_id) return @server1,@lb_ip,@my_pub_lb do
  provision(@server1)
  provision(@lb_ip)
  provision(@my_pub_lb)
  call run_rightscript_by_name(@server1.current_instance(), 'install_apache.sh')
  #call add_to_lb($subscription_id,@server1,@my_pub_lb)
end

define add_to_lb($subscription_id,@server1,@my_pub_lb) return @server1,$nics,$a_nic do
  sub on_error: stop_debugging() do
    call start_debugging()
    @nics = rs_azure_networking_interfaces.interface.list(resource_group: @@deployment.name)
    call stop_debugging()
    call sys_log.detail(to_s(@nics))
    $a_nic = []
    foreach @nic in @nics do
      call sys_log.detail("nic:" + to_s(@nic))
      if @nic.name =~ @server1.name +"-default"
        $a_nic << @nic.name
      end
    end
    call update_network($subscription_id,$a_nic[0],@my_pub_lb)
  end
end

define update_network($subscription_id,$nic_name,@my_pub_lb) return @my_nic do
  sub on_error: stop_debugging() do
    call start_debugging()
    @my_nic = rs_azure_networking_interfaces.interface.show(resource_group: @@deployment.name, name: $nic_name)
    call stop_debugging()
    $object = to_object(@my_nic)
    call sys_log.detail("object:" + to_s($object)+"\n")
    $fields = $object["details"]
    call sys_log.detail("fields:" + to_s($fields) + "\n")
    $nic = $fields[0]
    call sys_log.detail("nic:" + to_s($nic))
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"] = []
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0] = {}
    $nic["properties"]["ipConfigurations"][0]["properties"]["loadBalancerBackendAddressPools"][0]["id"] = "/subscriptions/"+$subscription_id+"/resourceGroups/"+@@deployment.name+"/providers/Microsoft.Network/loadBalancers/"+@my_pub_lb.name+"/backendAddressPools/pool1"
    call sys_log.detail("updated_nic:" + to_s($nic))
    call start_debugging()
    @updated_nic = @my_nic.update($nic)
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