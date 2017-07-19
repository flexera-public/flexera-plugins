name 'GCP Cloud DNS Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - Cloud DNS - Test CAT"
import "plugins/googledns"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
    like $googledns.google_project
end

parameter "dns_zone" do
    label "DNS Managed Zone - Name"
    category "Managed Zone"
    type "string"
    min_length 1
end

parameter "param_dns_name" do
    label "DNS Managed Zone - DNS Name"
    category "Managed Zone"
    type "string"
    min_length 1
end

parameter "param_zone_desc" do
    label "DNS Managed Zone - Description"
    category "Managed Zone"
    type "string"
end

parameter "param_record_name" do
    type "string"
    label "record name"
end

parameter "param_zone_id" do
    type "string"
    label "zone id"
end 

##########################
##########################
#######  Outputs  ########
##########################
##########################

output "zone_creationTime" do
    label "Creation Time"
    category "DNS Managed Zone"
    default_value @my_zone.creationTime 
end

output "zone_description" do
    label "Description"
    category "DNS Managed Zone"
    default_value @my_zone.description
end

output "zone_dnsName" do
    label "DNS Name"
    category "DNS Managed Zone"
    default_value @my_zone.dnsName
end

output "zone_id" do
    label "ID"
    category "DNS Managed Zone"
    default_value @my_zone.id 
end 

output "kind" do
    label "Kind"
    category "DNS Managed Zone"
    default_value @my_zone.kind
end

output "zone_name" do
    label "Name"
    category "DNS Managed Zone"
    default_value @my_zone.name
end

output "zone_nameservers" do 
    label "Nameservers"
    category "DNS Managed Zone"
end

output "proj_kind" do
    label "Kind"
    category "Project"
end

output "proj_number" do
    label "Number"
    category "Project"
end

output "proj_id" do
    label "ID"
    category "Project"
end

output "proj_zone_quota" do
    label "Managed Zones - Quota"
    category "Project"
end 

output "proj_records_per_rrset" do
    label "Resource Records Per Resource Record Sets - Quota"
    category "Project"
end

output "proj_add_per_change" do
    label "Resource Record Sets Additions Per Change - Quota"
    category "Project"
end

output "proj_del_per_change" do
    label "Resource Record Sets Deletions Per Change - Quota"
    category "Project"
end

output "proj_rrset_per_zone" do
    label "Resource Record Sets Per Managed Zone - Quota"
    category "Project"
end

output "proj_data_size_per_change" do
    label "Resource Record Data Size Per Change - Quota"
    category "Project"
end

output "record_name" do
    label "Record Name"
    category "DNS Record"
    default_value @my_recordset.name
end

output "record_rrdatas" do
    label "Record RRDatas"
    category "DNS Record"
end

output "record_type" do
    label "Record Type"
    category "DNS Record"
    @my_recordset.type
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
    
resource "my_zone", type: "clouddns.managedZone" do
    name $dns_zone
    description $param_zone_desc
    dns_name $param_dns_name
end

resource "my_recordset", type: "clouddns.resourceRecordSet" do
    name join([$param_record_name, ".", $param_dns_name ])
    ttl 300
    type "A"
    rrdatas "4.3.2.1"
end

##########################
##########################
###### Operations ########
##########################
##########################

operation "launch" do
    definition "launch_handler"
    output_mappings do {
        $zone_nameservers => $nameservers,
        $record_ttl => $ttl,
        $record_rrdatas => $rrdatas
    } end
end 

operation "terminate" do
    definition "terminate"
end

operation "get_dns_quotas" do
    definition "get_project"
    output_mappings do {
        $proj_kind => $kind,
        $proj_number => $number,
        $proj_id => $id,
        $proj_zone_quota => $zone_quota,
        $proj_records_per_rrset => $records_per_rrset,
        $proj_add_per_change => $add_per_change,
        $proj_del_per_change => $del_per_change,
        $proj_rrset_per_zone => $rrset_per_zone,
        $proj_data_size_per_change => $data_size_per_change
    } end
end 

##########################
##########################
###### Definitions #######
##########################
##########################

define launch_handler(@my_zone, @my_recordset) return @my_zone, @my_recordset, $nameservers, $rrdatas, $ttl do
    provision(@my_zone)
    $nameservers = to_s(@my_zone.nameServers)
    provision(@my_recordset)
    $rrdatas = to_s(@my_recordset.rrdatas)
    $ttl = to_s(@my_recordset.ttl)
end 

define terminate(@my_zone, @my_recordset) do
    delete(@my_recordset)
    delete(@my_zone)
end 

define get_project(@my_zone) return $kind,$number,$id,$zone_quota,$records_per_rrset,$add_per_change,$del_per_change,$rrset_per_zone,$data_size_per_change do
    @project = @my_zone.project()
    $kind = @project.kind
    $number = to_s(@project.number)
    $id = @project.id
    $zone_quota = to_s(@project.managedZones_quota)
    $records_per_rrset = to_s(@project.resourceRecordsPerRrset_quota)
    $add_per_change = to_s(@project.rrsetAdditionsPerChange_quota)
    $del_per_change = to_s(@project.rrsetDeletionsPerChange_quota)
    $rrset_per_zone = to_s(@project.rrsetsPerManagedZone_quota)
    $data_size_per_change = to_s(@project.totalRrdataSizePerChange_quota)
end 


