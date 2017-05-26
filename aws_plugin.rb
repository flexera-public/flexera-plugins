name 'AWS RDS Plugin Example'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Relational Database Service"
 

output 'sg_name' do
  label 'DBSecurityGroup name'
  default_value join(['', @my_sec_group.DBSecurityGroupName])
end

output 'sg_description' do
  label 'DBSecurityGroup description'
  default_value join(['', @my_sec_group.DBSecurityGroupDescription])
end

output 'sg_owner_id' do
  label 'DBSecurityGroup owner id'
  default_value join(['', @my_sec_group.OwnerId])
end

output 'list_sg' do
  label 'list action'
end

plugin "rs_aws_rds" do
  endpoint do
    default_host "rds.us-east-1.amazonaws.com"
    default_scheme "https"
    path "/"
    query do {
      "Version" => "2014-10-31"
    } end
  end
 
  type "security_groups" do
    href_templates "/?Action=DescribeDBSecurityGroups&DBSecurityGroupName={{//DBSecurityGroup/DBSecurityGroupName}}"
    provision 'provision_sg'
    delete    'delete_sg'


    field "name" do
      alias_for "DBSecurityGroupName"
      type      "string"
      location  "query"
    end

    field "description" do
      alias_for "DBSecurityGroupDescription"
      type      "string"
      location  "query"
    end
 
    output_path "//DBSecurityGroup"
 
    output 'DBSecurityGroupDescription' do
      body_path "DBSecurityGroupDescription"
      type "simple_element"
    end

    output 'OwnerId' do
      body_path "OwnerId"
      type "simple_element"
    end

    output 'DBSecurityGroupName' do
      body_path 'DBSecurityGroupName'
      type "simple_element"
    end 

    action "create" do
      verb "POST"
      path "/?Action=CreateDBSecurityGroup"
    end

    action "destroy" do
      verb "POST"
      path "$href?Action=DeleteDBSecurityGroup"
    end
 
    action "get" do
      verb "POST"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeDBSecurityGroups"
    end

  end
end

resource_pool "do_pool" do
  plugin $rs_aws_rds

  auth "key", type: "aws" do
    version     4
    service    'rds'
    region     'us-east-1'
    access_key cred('qa_aws_access_key')
    secret_key cred('qa_aws_secret_key')
  end

end

resource "my_sec_group", type: "rs_aws_rds.security_groups" do
  name        "ss_api_db_security_group"
  description "a simple db security group"
end

operation 'list_sg' do
  definition 'list_security_groups'
  output_mappings do{
    $list_sg => $object
  } end
end

define provision_sg(@declaration) return @sec_group do
  sub on_error: handle_error() do
    initiate_debug_report()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    @sec_group = rs_aws_rds.security_groups.create($fields)
    @sec_group = @sec_group.get()
  end
end

define list_security_groups() return $object do
  @security_groups = rs_aws_rds.security_groups.list()

  $object = to_object(first(@security_groups))

  $object = to_s($object)
end

define handle_error() do
  $error_info = complete_debug_report()
end

define delete_sg(@sec_group) do
  sub on_error: handle_error() do
    initiate_debug_report()
    @sec_group.destroy()
  end
end