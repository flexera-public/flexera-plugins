name 'aws_sdb_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - SimpleDB"
long_description "Version: 1.0"
package "plugins/rs_aws_sdb"
import "sys_log"
import "plugin_generics"

plugin "rs_aws_sdb" do
  endpoint do
    default_scheme "https"
    path "/"
    query do {
      "Version" => "2009-04-15"
    } end
  end

  type "domain" do
    field "domainname" do
      alias_for "DomainName"
      location "query"
      type "string"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateDomain"

      field "domainname" do
        alias_for "DomainName"
        location "query"
      end
    end

    action "deletedomain" do
      verb "GET"
      path "/?Action=DeleteDomain"
    end   

    action "domainmetadata" do
      verb "GET"
      path "/?Action=DomainMetadata"
    end

    action "listdomains" do
      verb "GET"
      path "/?Action=ListDomains"

      field "maxnumberofdomains" do
        alias_for "MaxNumberOfDomains"
        location "query"
      end
    end
    
    provision "provision_domain"   
    delete    "delete_domain"

  end
end

resource_pool "sdb" do
  plugin $rs_aws_sdb
  host "sdb.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'sdb'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_domain(@declaration) return @my_domain do
  $object = to_object(@declaration)
  $fields = $object["fields"]
  sub on_error: plugin_generics.stop_debugging() do
    call plugin_generics.start_debugging()
    @my_domain = rs_aws_sdb.domain.create($fields)
    sub on_error: skip do
      #
    end 
    call plugin_generics.stop_debugging()
  end
end

define handle_retries($attempts) do
  if $attempts <= 6
    sleep(10*to_n($attempts))
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("error:"+$_error["type"] + ": " + $_error["message"])
    call sys_log.detail("error:"+$_error["type"] + ": " + $_error["message"])
    log_error($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "retry"
  else
    raise $_errors
  end
end

define delete_domain(@my_domain) do
  sub on_error: handle_retries($my_domain) do
    call plugin_generics.start_debugging()
    rs_aws_sdb.domain.destroy(name: $domain_name)
    call plugin_generics.stop_debugging()
  end 
end