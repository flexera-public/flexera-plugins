name 'Infoblox IPAM Test CAT'
rs_ca_ver 20161221
short_description "Infoblox IPAM Test CAT"
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


##########################
##########################
####### Resources ########
##########################
##########################
    

resource "hostrecord", type: "rs_infoblox_ipam.record_host" do
    name $param_hostname
    ipv4addrs [{ ipv4addr:join(["func:nextavailableip:",$param_cidrblock]) }]
#    tunnel_token cred("INFOBLOX_TUNNEL_TOKEN")
end

##########################
##########################
###### Operations ########
##########################
##########################


#operation "get_record" do
#    definition "get_record"
#    output_mappings do {
#        $record_object => $object
#    } end
#end
#
#operation "launch" do
#    definition "launch_handler"
#    output_mappings do {
#        $record_name => $name,
#        $record_rrdatas => $rrdatas,
#        $record_type => $type,
#        $record_ttl => $ttl
#    } end
#end 


##########################
##########################
###### Definitions #######
##########################
##########################

define launch_handler(@my_recordset) return @my_recordset, $rrdatas, $type, $ttl, $name do
    provision(@my_recordset)
    $rrdatas = to_s(@my_recordset.rrdatas)
    $type = @my_recordset.type
    $ttl = to_s(@my_recordset.ttl)
    $name = @my_recordset.name
end 

define get_record(@my_recordset) return $object do
    @my_recordset = @my_recordset.get()
    $object = to_s(to_object(@my_recordset))
end
