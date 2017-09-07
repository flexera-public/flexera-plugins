name 'Infoblox IPAM Test CAT'
rs_ca_ver 20161221
short_description "Infoblox IPAM Test CAT"

import "sys_log"
import "plugins/rs_infoblox_ipam"

##########################
##########################
###### Parameters ########
##########################
##########################


parameter "param_hostname" do
    label "Host Name"
    type "string"
end

parameter "param_domain" do
    label "Host Domain"
    type "string"
end

parameter "param_cidrblock" do
  label "Network CIDR to Use"
  type "string"
end

parameter "param_name_filter" do
  label "String to use to filter host name"
  type "string"
end

parameter "param_search_string" do
  label "Generic search string"
  type "string"
end

##########################
##########################
#######  Outputs  ########
##########################
##########################

output "host_name" do
    label "Host Name"
    category "Outputs"
    default_value @hostrecord.name
end

output "host_ipv4addr" do
    label "Host IPv4 Address"
    category "Outputs"
    default_value @hostrecord.ipv4addr
end

output "host_ipv6addr" do
    label "Host IPv6 Address"
    category "Outputs"
    default_value @hostrecord.ipv6addr
end

output "host_ref" do
    label "Host Reference"
    category "Outputs"
    default_value @hostrecord._ref
end

output "output_list" do
  label "Hosts List"
  category "Hosts List"
  default_value "Run \"More Actions -> Test list_by_name Action\""
end

output "output_search" do
  label "Searched Hosts List"
  category "Hosts List"
  default_value "Run \"More Actions -> Test search Action\""
end

##########################
##########################
####### Resources ########
##########################
##########################
    

resource "hostrecord", type: "rs_infoblox_ipam.record_host" do
    name join([$param_hostname,".",$param_domain])
    ipv4addrs [{ ipv4addr:join(["func:nextavailableip:",$param_cidrblock]) }]
end

# Use this to test the "list_by_name" action defined in the plugin
operation "test_list_by_name" do
  label "Test list_by_name Action"
  definition "list_by_name"
  output_mappings do {
      $output_list => $host_list
  } end
end

operation "test_generic_search" do
  label "Test search Action"
  definition "generic_search"
  output_mappings do {
      $output_search => $searched_hosts
  } end
end

##########################
##########################
###### Operations ########
##########################
##########################

define list_by_name($param_name_filter) return $host_list do
  $hostrecords = rs_infoblox_ipam.record_host.list_by_name(name_filter: $param_name_filter)
  $host_list = to_s($hostrecords)
end

define generic_search($param_search_string) return $searched_hosts do
  $hostrecords = rs_infoblox_ipam.record_host.search(search_string: $param_search_string)  
  $searched_hosts = to_s($hostrecords)
end

define log($summary, $details) do
  rs_cm.audit_entries.create(notify: "None", audit_entry: { auditee_href: @@deployment, summary: $summary , detail: $details})
end