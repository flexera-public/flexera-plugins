name 'rs_fastly_ipaddress'
type 'plugin'
rs_ca_ver 20161221
short_description "Fastly Ipaddress List"
long_description "Version: 0.1"
package "plugins/rs_fastly_ipaddress"
import "sys_log"

plugin "rs_fastly_ipaddress" do
  endpoint do
    default_host "https://api.fastly.com"
    default_scheme "https"
  end

  type "public_ip_list" do
    href_templates "{{addresses[*] && '/public-ip-list' || null}}"
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