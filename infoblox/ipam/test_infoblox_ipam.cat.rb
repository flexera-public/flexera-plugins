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
    label "Host FQDN"
    type "string"
end

parameter "param_cidrblock" do
  label "Network CIDR to Use"
  type "string"
end

parameter "param_name_filter" do
  label "Regexp to filter host name"
  type "string"
end

##########################
##########################
#######  Outputs  ########
##########################
##########################

output "hostname" do
    label "Host Name"
    category "Outputs"
    default_value @hostrecord.host_name
end

output "hostaddr" do
    label "Host Address"
    category "Outputs"
    default_value @hostrecord.host_addr
end

output "hostref" do
    label "Host Reference"
    category "Outputs"
    default_value @hostrecord.host_ref
end

output "output_list" do
  label "Hosts List"
  category "Hosts List"
  default_value "Run \"More Actions\""
end

##########################
##########################
####### Resources ########
##########################
##########################
    

resource "hostrecord", type: "rs_infoblox_ipam.record_host" do
    name $param_hostname
    ipv4addrs [{ ipv4addr:join(["func:nextavailableip:",$param_cidrblock]) }]
end

operation "test_list_by_name" do
  label "Test list_by_name Action"
  definition "list_by_name"
  output_mappings do {
      $output_list => $host_list
  } end
end

##########################
##########################
###### Operations ########
##########################
##########################

define list_by_name($param_name_filter) return $host_list do
  $hostrecords = rs_infoblox_ipam.record_host.list_by_name(name_filter: $param_name_filter)
  call log("host records", to_s($hostrecords))
  foreach $hostrecord in $hostrecords[0] do
    call log("host record item", to_s($hostrecord))
  end
  
  $host_list = to_s($hostrecords)
end

define log($summary, $details) do
  rs_cm.audit_entries.create(notify: "None", audit_entry: { auditee_href: @@deployment, summary: $summary , detail: $details})
end