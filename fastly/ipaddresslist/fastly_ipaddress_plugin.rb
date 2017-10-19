#fastly plugin
name 'rs_fastly_ipaddress'
type 'plugin'
rs_ca_ver 20161221
short_description "Fastly Ipaddress List"
long_description "Version: 0.1"
package "plugins/rs_fastly_ipaddress"
import "sys_log"

plugin "rs_fastly_ipaddress" do
  endpoint do
    default_host "https://api.fastly.com"  # Change to wstunnel10-1 if applicable
    default_scheme "https"
  end

  type "public_ip_list" do
    href_templates "{{addresses[*] && '/public-ip-list' || null}}"  # The leading slash is makes the reference that comes back from infoblox href-like
    provision "no_operation"
    delete "no_operation"

    action "show" do
      path "/public-ip-list"
      verb "GET"
    end
    output "addresses"
  end
end

resource_pool "rs_fastly_ipaddress" do
  plugin $rs_fastly_ipaddress
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

output "addresses" do
  label "Host IPv4 Address"
  category "Outputs"
  default_value $address_list
end

operation "launch" do
  label "Launch"
  definition "gen_launch"
  output_mappings do {
      $addresses => $address_list
  } end
end

define gen_launch() return @fastly,$address_list do
  call start_debugging()
  @fastly = rs_fastly_ipaddress.public_ip_list.show()
  call stop_debugging()
  call start_debugging()
  $address_list = to_s(@fastly.addresses)
  call stop_debugging()
end
