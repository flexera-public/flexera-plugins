name 'GCP Cloud DNS Record - Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - Cloud DNS - Test CAT - Record Only"
import "plugins/googledns"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
    like $googledns.google_project
    default "rightscale.com:services1"
end

parameter "dns_zone" do
    like $googledns.dns_zone
end

parameter "dns_name" do
    label "DNS Name"
    type "string"
    default "ss-plugin.com."
end

parameter "param_record_name" do
    type "string"
    label "record name"
    default "foobar"
end

##########################
##########################
#######  Outputs  ########
##########################
##########################

output "record_object" do
    label "Record Object"
    category "Record"
end

output "record_name" do
    label "Record Name"
    category "DNS Record"
end

output "record_rrdatas" do
    label "Record RRDatas"
    category "DNS Record"
end

output "record_type" do
    label "Record Type"
    category "DNS Record"
end

output "record_ttl" do
    label "Record TTL"
    category "DNS Record"
end 


##########################
##########################
####### Resources ########
##########################
##########################
    

resource "my_recordset", type: "clouddns.resourceRecordSet" do
    name join([$param_record_name, ".", $dns_name ])
    ttl 300
    type "A"
    rrdatas "4.3.2.1"
end

##########################
##########################
###### Operations ########
##########################
##########################


operation "get_record" do
    definition "get_record"
    output_mappings do {
        $record_object => $object
    } end
end

operation "launch" do
    definition "launch_handler"
    output_mappings do {
        $record_name => $name,
        $record_rrdatas => $rrdatas,
        $record_type => $type,
        $record_ttl => $ttl
    } end
end 


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
