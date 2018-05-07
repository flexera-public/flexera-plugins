name 'sdb test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - SimpleDB"
import "plugins/rs_aws_sdb"

output "list_simpledb_domains" do
  label "list simpledb domains"
end

output "list_simpledb_domainmetadata" do
    label "get domainmetadata"
end

#New SimpleDB Domain:
resource "mysimpledb", type: "rs_aws_sdb.domain" do
  domainname join(["my-simpledb-", last(split(@@deployment.href, "/"))])
end

operation "list_simpledb_domains" do
  definition "list_simpledb_domains"
  output_mappings do {
    $list_simpledb_domains => $list_object
  } end
end

define list_simpledb_domains() return $list_object do
  @sdb = rs_aws_sdb.domain.listdomains(maxnumberofdomains: "100")
  $list_object = to_object(@sdb)
  $list_object = to_s($list_object)
end

#
#New DomainMetadata:
operation "list_simpledb_domainmetadata" do
    definition "list_simpledb_domainmetadata"
    output_mappings do {
        $list_simpledb_domainmetadata => $metadata_object
    } end
end

define list_simpledb_domainmetadata(@mysimpledb) return $metadata_object do
    @sdb = rs_aws_sdb.domain.domainmetadata(domainname: @mysimpledb.domainname)
    $metadata_object = to_object(@sdb)
    $metadata_object = to_s($metadata_object)
end


#operation "check_if_empty" do
#  definition "check_if_empty"
#  output_mappings do {
#    $empty => $value
#  } end
#end

#define check_if_empty($db_href) return $value do
#    @rds = rs_aws_rds.db_instance.get(href: $db_href)
#    if empty?(@rds)
#      $value = "EMPTY!"
#    else
#      $value = "NOT EMPTY!"
#    end
#end
