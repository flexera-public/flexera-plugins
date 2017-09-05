# Infloblox IPAM plugin
#
# API Doc: https://ipam.illinois.edu/wapidoc/
#
# Helpful notes:
# * _return_fields=ipv4addrs is a useful parameter since it ensures the results from API calls contain structured response. Very important for the POST (create) since without it simple string is returned.


name 'rs_infoblox_ipam'
type 'plugin'
rs_ca_ver 20161221
short_description "Infoblox IPAM"
long_description "Version: 0.1"
package "plugins/rs_infoblox_ipam"
import "sys_log"

plugin "rs_infoblox_ipam" do
  
  parameter "tunnel_token" do
    type "string"
    label "wsTunnel token"
    description "wsTunnel token"
  end
  
  endpoint do
    default_host "https://wstunnel1-1.rightscale.com"  # Change to wstunnel10-1 if applicable
    default_scheme "https"
    path "_token/$tunnel_token/wapi/v2.2.2/"
  end
  
  type "record_host" do
    href_templates "/{{_ref}}"  # The leading slash is makes the reference that comes back from infoblox href-like
    provision "provision_record_host"
    delete "delete_record_host"
 
    # The FQDN of the host to which the IP is being allocated.
    # It must contain the zone (domain) and the infoblox service account must have write permissions.
    # E.g. myserver.example.com where myserver is the host name and example.com is the zone.
    field "name" do
      type "string"
      location "body"
      required true
    end
    
    # An array of hashes.
    # To get the next available IP use this (where the CIDR is a network to which the infoblox service account has write access).
    #   ipv4addrs [{ "ipv4addr":"func:nextavailableip:10.1.124.0/24" }]
    # To get a specific IP use this (again the IP address must be in network to which the service account has access.
    #   ipv4addrs:[{ "ipv4addr":"10.1.124.53" }]    
    field "ipv4addrs" do
      type "array"
      location "body"
      required true
    end
    
    action "show", "destroy" 
      
    action "create" do
      verb "POST"
      path "/record:host?_return_fields=ipv4addrs" 
    end
   
    output "host_ref" do
      body_path "_ref"
    end

    output "host_addr" do
      body_path "ipv4addrs[0].ipv4addr"
    end
    
    output "host_name" do
      body_path "ipv4addrs[0].host"
    end
  end    
end

resource_pool "infoblox_ipam" do
  plugin $rs_infoblox_ipam
  auth "ib_auth", type: "basic" do
    username cred('INFOBLOX_USERNAME')
    password cred('INFOBLOX_PASSWORD')
  end
  parameter_values do
    tunnel_token "WSTUNNEL_TOKEN" # REPLACE with the wsTunnel token BEFORE uploading
  end
end

define provision_record_host(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $type = $object["type"]
    $fields = $object["fields"]
    $host_name = $fields["name"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ",$type]))
    call sys_log.detail($object)
    call sys_log.detail(join(["Host Name: ", $host_name]))
    @operation = rs_infoblox_ipam.record_host.create($fields) 
    call sys_log.detail("CREATE HREF: "+to_s(@operation))
    call sys_log.detail("CREATE HREF OBJECT: "+to_s(to_object(@operation)))
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_record_host(@declaration) do
  call start_debugging()
  @declaration.destroy()
  call stop_debugging()
end

define no_operation(@declaration) do
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