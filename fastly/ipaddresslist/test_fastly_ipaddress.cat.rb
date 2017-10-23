name 'Fastly Ip Address Test CAT'
rs_ca_ver 20161221
short_description "Fastly Ip Address Test CAT"

import "sys_log"
import "plugins/rs_fastly_ipaddress"

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

define gen_launch() return @fastly,$address_list do
  call start_debugging()
  @fastly = rs_fastly_ipaddress.public_ip_list.show()
  call stop_debugging()
  call start_debugging()
  $address_list = to_s(@fastly.addresses)
  call stop_debugging()
end