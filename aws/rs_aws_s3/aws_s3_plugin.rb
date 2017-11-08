name 'aws_s3_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - S3 Plugin"
long_description "Version 1.0"
package "plugins/rs_aws_s3"
import "sys_log"

plugin "rs_aws_s3" do
  endpoint do
    default_host "s3.amazonaws.com"
    default_scheme "https"
    query do {
        "Version" => "2012-10-17"
    } end
  end

  type "bucket" do
    # bucket acl
    field "bucket_name" do
      type "string"
      required true
      location "path"
    end

    output "DisplayName","ID", "Permission","Date","Server"

    #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETpolicy.html
    action "policy" do
      verb "GET"
      path "/$bucket_name?policy"
    end
  
    #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETacl.html
    action "acl" do
      verb "GET"
      path "/$bucket_name?acl"
    end   

    provision "no_operation"
    delete "no_operation"
  end
end

resource_pool "s3" do
  plugin $rs_aws_s3
  host "s3.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    's3'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
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

operation "launch" do
  label "Launch"
  definition "gen_launch"
end

resource "my_bucketinfo", type: "rs_aws_s3.bucket" do
  bucket_name "tushar-rightscale"
end

define gen_launch(@my_bucketinfo) return @my_bucketinfo,@bucket,$policies,$acls do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@my_bucketinfo)
    $fields = $object["fields"]
    @bucket = rs_aws_s3.bucket.get($fields)
    $policies = @bucket.policies()
    $acls = @bucket.acls()
  end
  call stop_debugging()
end
